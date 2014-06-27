
Datastore = require "./DatabaseWrapper"
_ = require "underscore"
Player = require "../character/Player"
RestrictedNumber = require "restricted-number"
Q = require "q"
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"

class PlayerManager

  players: []
  playerHash: {}

  constructor: (@game) ->
    @db = new Datastore "players"
    @db.ensureIndex { fieldName: 'identifier', unique: true }
    @db.ensureIndex { fieldName: 'name', unique: true }

  retrievePlayer: (identifier, callback) ->
    @db.findOne {identifier: identifier}, (e, player) =>
      return if not player

      @game.broadcast MessageCreator.generateMessage "#{player.name} has joined #{Constants.gameName}!"
      player = @migratePlayer player
      player.playerManager = @
      callback player

  addPlayer: (identifier) ->
    return if _.findWhere @players, {identifier, identifier}
    @retrievePlayer identifier, (player) =>
      return if not player
      @players.push player
      @playerHash[identifier] = player

      @players = _.uniq @players

  removePlayer: (identifier) ->

    name = (_.findWhere @players, {identifier, identifier}).name

    @players = _.filter @players, (player) -> !player.identifier is identifier
    delete playerHash[identifier]

    @game.broadcast MessageCreator.generateMessage "#{name} has left #{Constants.gameName}!"

  registerPlayer: (options, middleware, callback) ->

    @game.broadcast MessageCreator.genericMessage "Welcome #{options.name} to Idletopia!"
    playerObject = new Player options
    playerObject.playerManager = @
    playerObject.initialize()
    playerObject.playerManager = null

    @db.insert playerObject, (iErr, doc) =>
      if iErr
        console.error "Player creation error: #{iErr}"
        callback iErr
        return

      playerObject.playerManager = @
      @playerHash[options.identifier] = playerObject
      @players.push playerObject

      callback { success: true, name: options.name }

  savePlayer: (player) ->
    player.playerManager = null
    @db.update { identifier: player.identifier }, player, (e) =>
      console.error "Save error: #{e}" if e
      player.playerManager = @

  playerTakeTurn: (identifier) ->
    return if not identifier or not (identifier of @playerHash)
    @playerHash[identifier].takeTurn()

  registerLoadAllPlayersHandler: (@playerLoadHandler) ->
    console.log "Registered AllPlayerLoad handler."

  migratePlayer: (player) ->
    return if not player

    loadRN = (obj) ->
      return if not obj
      obj.__proto__ = RestrictedNumber.prototype
      obj

    loadProfession = (professionName) ->
      new (require "../character/classes/#{professionName}")()

    _.forEach ['hp', 'mp', 'special', 'level', 'xp'], (item) ->
      player[item] = loadRN player[item]

    player.gold = 0 if not player.gold

    player.__proto__ = Player.prototype
    player.playerManager = @
    player.isBusy = false

    if not player.professionName
      player.changeProfession "Generalist"
    else
      player.profession = loadProfession player.professionName
      player.profession.load player

    player

module.exports = exports = PlayerManager