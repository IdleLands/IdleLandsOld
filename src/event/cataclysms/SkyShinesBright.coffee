
Cataclysm = require "../Cataclysm"
_ = require "underscore"
MessageCreator = require "../../system/MessageCreator"

class SkyShinesBright extends Cataclysm
  constructor: (game) ->
    super game, "brightshine"

  go: ->
    @map = @pickRandomMap()
    affected = @getPlayersInMap @map
    message = "The sky shines brightly in #{@map}#{if affected.length >0 then "!" else ", but no one was around to see it."}"
    @game.broadcast MessageCreator.genericMessage message

    _.each affected, (player) =>
      @affect player
      callback = ->
      @game.eventHandler.doEventForPlayer player.name, callback, 'blessXp'

module.exports = exports = SkyShinesBright