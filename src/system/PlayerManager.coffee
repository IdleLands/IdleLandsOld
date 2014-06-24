
Datastore = require "nedb"
_ = require "underscore"
Player = require "../character/Player"
RestrictedNumber = require "restricted-number"
Q = require "q"
MessageCreator = require "./MessageCreator"

class PlayerManager

  players: []

  salt: "IdleGame"

  constructor: (@game) ->
    @db = new Datastore { filename: "data/players.ildb", autoload: true }
    @db.ensureIndex { fieldName: 'identifier', unique: true }
    @db.ensureIndex { fieldName: 'name', unique: true }

  retrievePlayer: (identifier, callback) ->
    @db.findOne {identifier: identifier}, (e, player) =>
      return if not player
      player = @migratePlayer player
      player.playerManager = @
      callback player

  addPlayer: (identifier) ->
    return if _.findWhere @players, {identifier, identifier}
    @retrievePlayer identifier, (player) =>
      return if not player
      @players.push player

      @players = _.uniq @players

      @game.broadcast MessageCreator.generateMessage "#{player.name} has joined!"

  removePlayer: (identifier) ->

    name = (_.findWhere @players, {identifier, identifier}).name

    @players = _.filter @players, (player) -> !player.identifier is identifier

    @game.broadcast MessageCreator.generateMessage "#{name} has left!"

  registerPlayer: (options, middleware, callback) ->

    playerObject = new Player options

    @db.insert playerObject, (iErr) =>
      if iErr
        console.error "Player creation error: #{iErr}"
        callback iErr
        return

      playerObject.playerManager = @
      @players.push playerObject

      callback { success: true, name: options.name }

  savePlayer: (player) ->
    player.playerManager = null
    @db.update { identifier: player.identifier }, player, (e) ->
      console.error "Save error: #{e}" if e

  registerLoadAllPlayersHandler: (@playerLoadHandler) ->
    console.log "Registered AllPlayerLoad handler."
    identifierArray = @playerLoadHandler()

    _.forEach identifierArray, (identifier) ->
      console.log "#{identifier} being added"

  migratePlayer: (player) ->
    return if not player

    loadRN = (obj) ->
      return if not obj
      obj.__proto__ = RestrictedNumber.prototype

    player.gold = 0 if not player.gold
    player.hp = loadRN player.hp
    player.mp = loadRN player.mp
    player.special = loadRN player.special
    player.level = loadRN player.level

    player.__proto__ = Player.prototype
    player.playerManager = @
    player

module.exports = exports = PlayerManager