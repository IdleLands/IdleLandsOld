
_ = require "lodash"
MessageCreator = require "../system/MessageCreator"

class Cataclysm

  constructor: (@game, @name) ->

  broadcastMessage: (message) ->
    @game.broadcast MessageCreator.genericMessage ">>> CATACLYSM: #{message}"

  pickRandomMap: ->
    _.sample _.keys @game.world.maps

  getPlayersInMap: (map) ->
    _.filter @game.playerManager.players, (player) -> player.map is map

  findRandomSetOfPlayers: ->
    @getPlayersInMap @pickRandomMap()

  allPlayers: ->
    @game.playerManager.players

  randomPlayer: ->
    _.sample @allPlayers()

  affect: (player) ->
    player.emit "event.cataclysms"
    player.emit "event.cataclysms.#{@name}"

  go: ->
    @game.errorHandler.captureException new Error "ERROR: THIS CATACLYSM DOESN'T SEEM TO WORK"

module.exports = exports = Cataclysm