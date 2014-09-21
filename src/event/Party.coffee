
_ = require "underscore"
_.str = require "underscore.string"
MessageCreator = require "../system/MessageCreator"
chance = new (require "chance")()

class Party
  constructor: (@game, players) ->
    players = [players] if not _.isArray players
    @players = []
    if (not players) or players.length < 1
      @disband()
      return
    @recruit players
    @name = @pickPartyName()
    @addGlobally()

  score: ->
    _.reduce @players, ((prev, player) -> prev + player.calc.totalItemScore()), 0

  getPartyName: ->
    if @players.length > 1 then @name else @players[0].name

  genNullPartyName: ->
    "The Null Party #{chance.integer min: 1, max: 1000}"

  pickPartyName: ->
    return @genNullPartyName() if not Party::partyGrammar?
    format = _.sample Party::partyGrammar
    return @genNullPartyName() if not format?
    arr =  format.split(" ")
    _.str.clean (_.reduce arr, (sentence, word) ->
      repl = null
      switch (word.trim())
        when '%noun%'
          repl = _.sample Party::nouns
        when '%preposition%'
          repl = _.sample Party::prepositions
        when '%article%'
          repl = _.sample Party::articles
        when '%adjective%'
          repl = _.sample Party::adjectives
        when '%conjunction%'
          repl = _.sample Party::conjunctions
        else
          repl = word.trim()
      sentence.push(repl?.trim())
      return sentence
    ,[]).join(" ").trim()

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
      if @players.length <= 1
        @disband()
        player.playerManager.game.broadcast MessageCreator.genericMessage "<player.name>#{player.name}</player.name> has disbanded <event.partyName>#{@name}</event.partyName>." if not forced
      else
        player.playerManager.game.broadcast MessageCreator.genericMessage "<player.name>#{player.name}</player.name> has left <event.partyName>#{@name}</event.partyName>."

    player.party = null

  disband: ->
    @game.parties = _.without @game.parties, @
    _.forEach @players, (player) => @playerLeave player, yes

module.exports = exports = Party
