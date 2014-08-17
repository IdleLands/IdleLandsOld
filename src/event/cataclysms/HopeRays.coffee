
Cataclysm = require "../Cataclysm"
_ = require "underscore"
MessageCreator = require "../../system/MessageCreator"

class HopeRays extends Cataclysm
  constructor: (game) ->
    super game, "hoperays"

  go: ->
    @map = @pickRandomMap()
    affected = @getPlayersInMap @map
    message = "Rays of hope flood #{@map} with mercy and blessing#{if affected.length >0 then "!" else ", but unfortunately no one important was there."}"
    @game.broadcast MessageCreator.genericMessage message

    _.each affected, (player) =>
      @affect player
      callback = ->
      @game.eventHandler.doEventForPlayer player.name, callback, 'blessXp'
      @game.eventHandler.doEventForPlayer player.name, callback, 'blessGold'
      @game.eventHandler.doEventForPlayer player.name, callback, 'blessItem'

module.exports = exports = HopeRays