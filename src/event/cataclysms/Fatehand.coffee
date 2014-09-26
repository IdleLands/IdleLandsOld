
Cataclysm = require "../Cataclysm"
_ = require "underscore"

class Fatehand extends Cataclysm
  constructor: (game) ->
    super game, "fatehand"

  go: ->
    affected = @allPlayers()
    message = "Everyone was touched by the hand of fate!"
    @broadcastMessage message

    _.each affected, (player) =>
      @affect player
      @game.eventHandler.doEventForPlayer player.name

module.exports = exports = Fatehand