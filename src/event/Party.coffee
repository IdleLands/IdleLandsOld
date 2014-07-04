
_ = require "underscore"
MessageCreator = require "../system/MessageCreator"

partyNames = [
  "Raging Wombats"
  "Wacky Narwhals"
  "Crazy Meerkats"
  "Band of Bros"
  "Singularity"
  "Fighting Foxes"
]

class Party
  constructor: (@players) ->
    @name = _.sample partyNames
    @setPlayersParty()

  setPlayersParty: ->
    _.forEach @players, (player) =>
      player.party = @

  playerLeave: (player) ->
    @players = _.without @players, player
    if @players.length <= 1
      @disband()
      player.playerManager.game.broadcast MessageCreator.genericMessage "#{player.name} has disbanded #{@name}."
    else
      player.playerManager.game.broadcast MessageCreator.genericMessage "#{player.name} has left #{@name}."

    delete player.party

  disband: ->
    _.forEach @players, (player) ->
      delete player.party

    delete @

module.exports = exports = Party