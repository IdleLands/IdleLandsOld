
Cataclysm = require "../Cataclysm"
_ = require "underscore"
MessageCreator = require "../../system/MessageCreator"

class BlackRays extends Cataclysm
  constructor: (game) ->
    super game, "blackrays"

  go: ->
    @map = @pickRandomMap()
    affected = @getPlayersInMap @map
    message = "Rays of darkness flood #{@map} with catastrophe#{if affected.length >0 then "!" else ", but thankfully no one important was there."}"
    @game.broadcast MessageCreator.genericMessage message

    _.each affected, (player) =>
      @affect player
      callback = ->
      @game.eventHandler.doEventForPlayer player.name, callback, 'forsakeXp'
      @game.eventHandler.doEventForPlayer player.name, callback, 'forsakeGold'
      @game.eventHandler.doEventForPlayer player.name, callback, 'forsakeItem'

module.exports = exports = BlackRays