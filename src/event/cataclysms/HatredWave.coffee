
Cataclysm = require "../Cataclysm"
_ = require "underscore"

###*
  * This cataclysm breaks up every party in the game.
  *
  * @name HatredWave
  * @category Cataclysms
  * @package Events
###
class HatredWave extends Cataclysm
  constructor: (game) ->
    super game, "hatredwave"

  go: ->
    affected = @allPlayers()
    message = "A wave of hatred washes over the world!"
    @broadcastMessage message

    _.each affected, (player) =>
      @affect player
      player.party?.disband()

module.exports = exports = HatredWave