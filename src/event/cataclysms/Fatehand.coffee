
Cataclysm = require "../Cataclysm"
_ = require "underscore"
MessageCreator = require "../../system/MessageCreator"

class Fatehand extends Cataclysm
  constructor: (game) ->
    super game, "fatehand"

  go: ->
    affected = @allPlayers()
    message = "Everyone was touched by the hand of fate!"
    @game.broadcast MessageCreator.genericMessage message

    _.each affected, (player) =>
      @affect player
      @game.eventHandler.doEventForPlayer player.name

module.exports = exports = Fatehand