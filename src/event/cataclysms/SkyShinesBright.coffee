
Cataclysm = require "../Cataclysm"
_ = require "underscore"

class SkyShinesBright extends Cataclysm
  constructor: (game) ->
    super game, "skybrightshine"

  go: ->
    @map = @pickRandomMap()
    affected = @getPlayersInMap @map
    message = "The sky shines brightly in #{@map}#{if affected.length >0 then "!" else ", but no one was around to see it."}"
    @broadcastMessage message

    _.each affected, (player) =>
      @affect player
      callback = ->
      @game.eventHandler.doEventForPlayer player.name, 'blessXp', callback

module.exports = exports = SkyShinesBright