
Datastore = require "./DatabaseWrapper"
_ = require "underscore"
Player = require "../character/player/Player"
Equipment = require "../item/Equipment"
RestrictedNumber = require "restricted-number"
Q = require "q"
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"

class PlayerManager

  players: []
  playerHash: {}

  constructor: (@game) ->
    @db = new Datastore "players", (db) ->
      db.ensureIndex { identifier: 1 }, { unique: true }, ->
      db.ensureIndex { name: 1 }, { unique: true }, ->

  banPlayer: (identifer, callback) ->
    @db.update {identifier: identifier}, {banned: true}, {}, callback

  retrievePlayer: (identifier, callback) ->
    @db.findOne {identifier: identifier}, (e, player) =>
      console.error e if e
      if not player or player.banned or _.findWhere @players, {identifier: identifier}
        callback?()
        return

      player = @migratePlayer player
      player.playerManager = @
      callback player

  addPlayer: (identifier, suppress = no) ->
    return if _.findWhere @players, {identifier: identifier}
    @retrievePlayer identifier, (player) =>
      return if not player
      @players.push player
      @playerHash[identifier] = player
      @game.broadcast MessageCreator.generateMessage "#{player.name}, the level #{player.level.__current} #{player.professionName}, has joined #{Constants.gameName}!" if not suppress

      @players = _.uniq @players

  removePlayer: (identifier) ->

    name = (_.findWhere @players, {identifier, identifier})?.name
    return if not name

    @players = _.filter @players, (player) -> not player.identifier is identifier
    delete @playerHash[identifier]

    @game.broadcast MessageCreator.generateMessage "#{name} has left #{Constants.gameName}!"

  registerPlayer: (options, middleware, callback) ->

    playerObject = new Player options
    playerObject.playerManager = @
    playerObject.initialize()
    saveObj = @buildPlayerSaveObject playerObject

    @db.insert saveObj, (iErr) =>
      if iErr
        console.error "Player creation error: #{iErr}" if callback?
        callback?(iErr)
        return

      @game.broadcast MessageCreator.genericMessage "Welcome #{options.name} to #{Constants.gameName}!"
      @playerHash[options.identifier] = playerObject
      @players.push playerObject

      callback?({ success: true, name: options.name })

  buildPlayerSaveObject: (player) ->
    _.omit player, 'playerManager', 'party', 'personalities', 'calc', 'spellsAffectedBy', '_events'

  savePlayer: (player) ->
    savePlayer = @buildPlayerSaveObject player
    @db.update { identifier: player.identifier }, savePlayer, {upsert: true}, (e) ->
      console.error "Save error: #{e}" if e

  playerTakeTurn: (identifier) ->
    return if not identifier or not (identifier of @playerHash)
    @playerHash[identifier].takeTurn()

  registerLoadAllPlayersHandler: (@playerLoadHandler) ->
    console.log "Registered AllPlayerLoad handler."

  migratePlayer: (player) ->
    return if not player

    player.gold = (new RestrictedNumber 0, 9999999999, 0) if not player.gold or not player.gold?.maximum

    loadRN = (obj) ->
      return if not obj
      obj.__current = 0 if _.isNaN obj.current
      obj.__proto__ = RestrictedNumber.prototype
      obj

    loadProfession = (professionName) ->
      new (require "../character/classes/#{professionName}")()

    loadEquipment = (equipment) ->
      _.forEach equipment, (item) ->
        item.__proto__ = Equipment.prototype

    _.forEach ['hp', 'mp', 'special', 'level', 'xp', 'gold'], (item) ->
      player[item] = loadRN player[item]

    player.__proto__ = Player.prototype

    player.playerManager = @
    player.isBusy = false
    player.loadCalc()

    if not player.equipment
      player.generateBaseEquipment()
    else
      player.equipment = loadEquipment player.equipment

    if not player.professionName
      player.changeProfession "Generalist"
    else
      player.profession = loadProfession player.professionName
      player.profession.load player

    if not player.personalityStrings
      player.personalityStrings = []
      player.personalities = []
    else
      player.rebuildPersonalityList()

    player.spellsAffectedBy = []

    player.lastLogin = new Date()

    player.statistics = {} if not player.statistics

    player.setMaxListeners 100
    player.wildcard = yes

    @beginWatchingPlayerStatistics player

    player

  getPlayerByName: (playerName) ->
    _.findWhere @players, {name: playerName}

  getPlayerById: (playerId) ->
    _.findWhere @players, {identifier: playerId}

  beginWatchingPlayerStatistics: (player) ->

    maxStat = (stat, val) ->
      val = Math.abs val
      player.statistics[stat] = 0 if not stat of player.statistics or _.isNaN player.statistics[stat]
      player.statistics[stat] = Math.max val, player.statistics[stat]

    addStat = (stat, val, intermediate) ->
      player.statistics[intermediate] = {} if intermediate and not (intermediate of player.statistics)
      root = if intermediate then player.statistics[intermediate] else player.statistics
      val = Math.abs val
      root[stat] = 0 if not (stat of root) or _.isNaN root[stat]
      root[stat] += val

    player.onAny ->

      switch @event
        when "combat.self.heal"
          maxStat "calculated max heal given", arguments[1].damage
          addStat "calculated total heals given", arguments[1].damage

        when "combat.self.healed"
          addStat "calculated heal received", arguments[1].damage

        when "combat.self.damage"
          maxStat "calculated max damage given", arguments[1].damage
          addStat "calculated total damage given", arguments[1].damage

        when "combat.self.damaged"
          addStat "calculated damage received", arguments[1].damage

        when "combat.self.kill"
          addStat arguments[0].name, 1, "calculated kills"

      @event = @event.split(".").join " "
      player.statistics[@event] = 0 if not @event of player.statistics or _.isNaN player.statistics[@event]
      player.statistics[@event]++

module.exports = exports = PlayerManager
