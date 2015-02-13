
Cataclysm = require "../Cataclysm"
_ = require "lodash"

`/**
  * This cataclysm forsakes your experiences.
  *
  * @name SkyGlowsScornfully
  * @category Cataclysms
  * @package Events
*/`
class SkyGlowsScornfully extends Cataclysm
  constructor: (game) ->

    ##TAG:EVENT_EVENT: cataclysm.skyscornglow | cataclysm | Emitted when a player is affected by the skyscornglow cataclysm
    super game, "skyscornglow"

  go: ->
    @map = @pickRandomMap()
    affected = @getPlayersInMap @map
    message = "The sky glows scornfully in #{@map}#{if affected.length >0 then "!" else ", but no one was around to see it."}"
    @broadcastMessage message

    _.each affected, (player) =>
      @affect player
      callback = ->
      @game.eventHandler.doEventForPlayer player.name, 'forsakeXp', callback

module.exports = exports = SkyGlowsScornfully