
_ = require "underscore"
MessageCreator = require "../system/MessageCreator"

class Party
  constructor: (@game, @players) ->
    @players = [@players] if not _.isArray @players
    @name = @pickPartyName()
    return if not @name or not @players
    @addGlobally()
    @setPlayersParty()

  getPartyName: ->
    if @players.length > 1 then @name else @players[0].name

  pickPartyName: ->
    return "The Null Party" if not Party::partyNames
    _.sample _.difference Party::partyNames, _.pluck @game.parties, 'name'

  addGlobally: ->
    if not @game.parties
      @game.parties = []

    @game.parties.push @

  setPlayersParty: ->
    _.forEach @players, (player) =>
      player.emit "party.join"
      player.party = @

  playerLeave: (player) ->
    @players = _.without @players, player
    player.emit "party.leave"
    if @players.length <= 1
      @disband()
      player.playerManager.game.broadcast MessageCreator.genericMessage "#{player.name} has disbanded #{@name}."
    else
      player.playerManager.game.broadcast MessageCreator.genericMessage "#{player.name} has left #{@name}."

    delete player.party

  disband: ->
    @game.parties = _.without @game.parties, @
    _.forEach @players, (player) ->
      player.emit "party.leave"
      delete player.party

module.exports = exports = Party