
_ = require "underscore"
_.str = require "underscore.string"
MessageCreator = require "../system/MessageCreator"
chance = new (require "chance")()

class Party
  constructor: (@game, players) ->
    players = [players] if not _.isArray players
    @players = []
    @name = @pickPartyName()
    if (not players) or players.length < 1
      @disband()
      return
    @recruit players
    @addGlobally()

  score: ->
    _.reduce @players, ((prev, player) -> prev + player.calc.totalItemScore()), 0

  getPartyName: ->
    if @players.length > 1 then @name else @players[0].name

  pickPartyName: ->
    @game.componentDatabase.generatePartyName()

  addGlobally: ->
    if not @game.parties
      @game.parties = []

    @game.parties.push @

  addPlayer: (player) ->
    @recruit [player]

  recruit: (players) ->
    _.forEach players, (player) =>
      return if player of @players
      player.emit "player.party.join"
      player.party = @
      player.partyName = if @players.length > 1 then @name else ''
      @players.push player

  playerLeave: (player, forced = no) ->
    @players = _.without @players, player
    player.emit "player.party.leave", player, @
    player.partyName = ''

    # forced = yes means disband() called this
    if not forced

      message = ''

      if @players.length <= 1
        @disband()
        message = "<player.name>#{player.name}</player.name> has disbanded <event.partyName>#{@name}</event.partyName>."
      else
        message = "<player.name>#{player.name}</player.name> has left <event.partyName>#{@name}</event.partyName>."

      @game.eventHandler.broadcastEvent {message: message, player: player, type: 'party'}

    player.party = null

  disband: ->
    @game.parties = _.without @game.parties, @
    _.forEach @players, (player) => @playerLeave player, yes

module.exports = exports = Party
