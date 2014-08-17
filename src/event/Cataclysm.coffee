
_ = require "underscore"

class Cataclysm

  constructor: (@game, @name) ->

  pickRandomMap: ->
    _.sample _.keys @game.world.maps

  getPlayersInMap: (map) ->
    _.filter @game.playerManager.players, (player) -> player.map is map

  findRandomSetOfPlayers: ->
    @getPlayersInMap @pickRandomMap()

  affect: (player) ->
    player.emit "event.cataclysms"
    player.emit "event.cataclysms.#{@name}"

  go: ->
    console.error "ERROR: THIS CATACLYSM DOESN'T SEEM TO WORK"

module.exports = exports = Cataclysm