
_ = require "underscore"
MessageCreator = require "../system/MessageCreator"

class Party
  #TODO random party names because wynaut
  constructor: (@players) ->
    @setPlayersParty()

  setPlayersParty: ->
    _.forEach @players, (player) =>
      player.party = @

  playerLeave: (player) ->
    @players = _.without @players, player
    if @players.length is 0
      player.playerManager.game.broadcast MessageCreator.genericMessage "#{player.name} has disbanded the party."
    else
      player.playerManager.game.broadcast MessageCreator.genericMessage "#{player.name} has left the party."

    delete player.party

  disband: ->
    _.forEach @players, (player) ->
      delete player.party

    delete @

module.exports = exports = Party