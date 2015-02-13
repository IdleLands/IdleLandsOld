
Cataclysm = require "../Cataclysm"
_ = require "lodash"

`/**
  * This cataclysm gives you some brightening experiences.
  *
  * @name SkyShinesBright
  * @category Cataclysms
  * @package Events
*/`
class SkyShinesBright extends Cataclysm
  constructor: (game) ->

    ##TAG:EVENT_EVENT: cataclysm.skybrightshine | cataclysm | Emitted when a player is affected by the skybrightshine cataclysm
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