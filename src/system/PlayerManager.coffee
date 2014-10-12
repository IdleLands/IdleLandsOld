
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

      db.update {}, {$set:{isOnline: no}}, {multi: yes}, ->

  randomPlayer: ->
    _.sample @players

  banPlayer: (name, callback) ->
    @db.update {name: name}, {banned: true}, {}, callback

  unbanPlayer: (name, callback) ->
    @db.update {name: name}, {banned: false}, {}, callback

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
    return if _.findWhere @players, {identifier: identifier} or identifier of @playerHash
    @retrievePlayer identifier, (player) =>
      return if not player
      player.isOnline = yes
      @players.push player
      @playerHash[identifier] = player
      @game.broadcast "#{player.name}, the level #{player.level.__current} #{player.professionName}, has joined #{Constants.gameName}!" if not suppress

      @players = _.uniq @players

  removePlayer: (identifier) ->

    player = _.findWhere @players, {identifier, identifier}
    return if not player

    player.isOnline = no
    @savePlayer player

    name = player.name

    @players = _.reject @players, (player) -> player.identifier is identifier
    delete @playerHash[identifier]

    @game.broadcast "#{name} has left #{Constants.gameName}!"

  registerPlayer: (options, middleware, callback) ->

    playerObject = new Player options
    playerObject.playerManager = @
    playerObject.initialize()
    playerObject.isOnline = yes
    playerObject.registrationDate = new Date()
    saveObj = @buildPlayerSaveObject playerObject
    saveObj._events = {}

    @db.insert saveObj, (iErr) =>
      if iErr
        console.error "Player creation error: #{iErr}", playerObject if callback?
        callback?(iErr)
        return

      @game.broadcast MessageCreator.genericMessage "Welcome #{options.name} to #{Constants.gameName}!"
      @playerHash[options.identifier] = playerObject
      @players.push playerObject

      @beginWatchingPlayerStatistics playerObject

      callback?({ success: true, name: options.name })

  buildPlayerSaveObject: (player) ->
    calc = player.calc.base
    calcStats = player.calc.statCache
    ret = _.omit player, 'playerManager', 'party', 'personalities', 'calc', 'spellsAffectedBy', 'fled', '_events', 'profession', 'stepCooldown', '_id'
    ret._baseStats = calc
    ret._statCache = calcStats
    ret

  addForAnalytics: (player) ->
    playerObject = @buildPlayerSaveObject player
    playerObject.saveTime = new Date()
    @game.componentDatabase.insertNewAnalyticsPoint playerObject

  savePlayer: (player) ->
    savePlayer = @buildPlayerSaveObject player
    savePlayer.lastLogin = new Date()
    @db.update { identifier: player.identifier }, savePlayer, {upsert: true}, (e) ->
      console.error "Save error: #{e}" if e

  playerTakeTurn: (identifier) ->
    return if not identifier or not (identifier of @playerHash)
    @playerHash[identifier].takeTurn()

  registerLoadAllPlayersHandler: (@playerLoadHandler) ->
    console.log "Registered AllPlayerLoad handler."

  migratePlayer: (player) ->
    return if not player

    player.registrationDate = new Date() if not player.registrationDate

    player.gold = (new RestrictedNumber 0, 9999999999, 0) if not player.gold or not player.gold?.maximum

    loadRN = (obj) ->
      return if not obj
      obj.__current = 0 if _.isNaN obj.__current
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

    player.wildcard = yes
    player.listenerTree = {}
    player._events = {}
    player.newListener = false
    player.setMaxListeners 100

    player.playerManager = @
    player.isBusy = false
    player.loadCalc()

    player.calc.itemFindRange()

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

    player.recalculateStats()

    player.spellsAffectedBy = []

    player.lastLogin = new Date()

    player.statistics = {} if not player.statistics
    player.permanentAchievements = {} if not player.permanentAchievements

    @beginWatchingPlayerStatistics player

    player

  getPlayerByName: (playerName) ->
    _.findWhere @players, {name: playerName}

  getPlayerById: (playerId) ->
    _.findWhere @players, {identifier: playerId}

  beginWatchingPlayerStatistics: (player) ->

    maxStat = (stat, val) ->
      val = Math.abs val
      player.statistics[stat] = 1 if not (stat of player.statistics) or _.isNaN player.statistics[stat]
      player.statistics[stat] = Math.max val, player.statistics[stat]

    addStat = (stat, val, intermediate) ->
      player.statistics[intermediate] = {} if intermediate and not (intermediate of player.statistics)
      root = if intermediate then player.statistics[intermediate] else player.statistics
      val = Math.abs val
      root[stat] = 0 if not (stat of root) or _.isNaN root[stat]
      root[stat] += val

    player.onAny ->
      player.statistics = {} if not player.statistics

      switch @event
        when "combat.self.heal"
          maxStat "calculated max healing given", arguments[1].damage
          addStat "calculated total healing given", arguments[1].damage

        when "combat.self.healed"
          addStat "calculated total healing received", arguments[1].damage

        when "combat.self.damage"
          maxStat "calculated max damage given", arguments[1].damage
          addStat "calculated total damage given", arguments[1].damage

        when "combat.self.damaged"
          addStat "calculated total damage received", arguments[1].damage

        when "combat.self.kill"
          addStat arguments[0].name, 1, "calculated kills" if not arguments[0].isMonster
          addStat arguments[0].professionName, 1, "calculated kills by class" if arguments[0].professionName

        when "player.profession.change"
          addStat arguments[2], 1, "calculated class changes"

        when "player.xp.gain"
          addStat "calculated total xp gained", arguments[1]

        when "player.xp.lose"
          addStat "calculated total xp lost", Math.abs arguments[1]

        when "player.gold.gain"
          addStat "calculated total gold gained", arguments[1]

        when "player.gold.lose"
          addStat "calculated total gold lost", Math.abs arguments[1]

        when "explore.transfer"
          addStat arguments[1], 1, "calculated map changes"

        when "event.bossbattle.win"
          addStat arguments[1], 1, "calculated boss kills"

      event = @event.split(".").join " "
      player.statistics[event] = 1 if not (event of player.statistics) or _.isNaN player.statistics[event]
      player.statistics[event]++
      player.statistics[event] = 1 if not player.statistics[event]

      player.checkAchievements()

module.exports = exports = PlayerManager
