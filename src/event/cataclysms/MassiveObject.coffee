
Cataclysm = require "../Cataclysm"
_ = require "underscore"
MessageCreator = require "../../system/MessageCreator"

class MassiveObject extends Cataclysm
  constructor: (game) ->
    super game, "massiveobject"

  go: ->
    massObj = @randomPlayer()
    affected = _.difference @allPlayers(), [massObj]
    return if not massObj or affected.length is 0
    message = "#{massObj.name} suddenly becomes a massive object, pulling all players to the nearby vicinity!"
    @game.broadcast MessageCreator.genericMessage message

    _.each affected, (player) =>
      @affect player
      player.x = massObj.x
      player.y = massObj.y
      player.map = massObj.map

module.exports = exports = MassiveObject