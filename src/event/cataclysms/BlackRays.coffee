
Cataclysm = require "../Cataclysm"
_ = require "underscore"

`/**
  * This cataclysm runs every negative event on a player. Sucks, huh?
  *
  * @name BlackRays
  * @category Cataclysms
  * @package Events
*/`
class BlackRays extends Cataclysm
  constructor: (game) ->
    super game, "blackrays"

  go: ->
    @map = @pickRandomMap()
    affected = @getPlayersInMap @map
    message = "Rays of darkness flood #{@map} with catastrophe#{if affected.length >0 then "!" else ", but thankfully no one important was there."}"
    @broadcastMessage message

    _.each affected, (player) =>
      @affect player
      callback = ->
      @game.eventHandler.doEventForPlayer player.name, 'forsakeXp', callback
      @game.eventHandler.doEventForPlayer player.name, 'forsakeGold', callback
      @game.eventHandler.doEventForPlayer player.name, 'forsakeItem', callback

module.exports = exports = BlackRays