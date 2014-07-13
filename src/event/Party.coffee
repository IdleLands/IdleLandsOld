
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
  constructor: (@game, @players) ->
    @players = [@players] if not _.isArray @players
    @name = @pickPartyName()
    return if not @name or not @players
    @addGlobally()
    @setPlayersParty()

  getPartyName: ->
    if @players.size > 1 then @name else @players[0].name

  pickPartyName: ->
    _.sample _.difference partyNames, _.pluck @game.parties, 'name'

  addGlobally: ->
    if not @game.parties
      @game.parties = []

    @game.parties.push @

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
    @game.parties = _.without @game.parties, @
    _.forEach @players, (player) ->
      delete player.party

module.exports = exports = Party