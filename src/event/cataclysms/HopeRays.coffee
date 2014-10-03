
Cataclysm = require "../Cataclysm"
_ = require "underscore"

class HopeRays extends Cataclysm
  constructor: (game) ->
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