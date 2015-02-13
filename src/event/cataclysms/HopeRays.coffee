
Cataclysm = require "../Cataclysm"
_ = require "lodash"

`/**
  * This cataclysm runs every positive event on every player. See, it's not so bad, now is it?
  *
  * @name HopeRays
  * @category Cataclysms
  * @package Events
*/`
class HopeRays extends Cataclysm
  constructor: (game) ->

    ##TAG:EVENT_EVENT: cataclysm.hoperays | cataclysm | Emitted when a player is affected by the hoperays cataclysm
    super game, "hoperays"

  go: ->
    @map = @pickRandomMap()
    affected = @getPlayersInMap @map
    message = "Rays of hope flood #{@map} with mercy and blessing#{if affected.length >0 then "!" else ", but unfortunately no one important was there."}"
    @broadcastMessage message

    _.each affected, (player) =>
      @affect player
      callback = ->
      @game.eventHandler.doEventForPlayer player.name, 'blessXp', callback
      @game.eventHandler.doEventForPlayer player.name, 'blessGold', callback
      @game.eventHandler.doEventForPlayer player.name, 'blessItem', callback

module.exports = exports = HopeRays