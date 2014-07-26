
_ = require "underscore"
_.str = require "underscore.string"
MessageCreator = require "../system/MessageCreator"

class Party
  constructor: (@game, @players) ->
    @players = [@players] if not _.isArray @players
    @name = @pickPartyName()
    return if not @name or not @players
    @addGlobally()
    @setPlayersParty()

  score: ->
    _.reduce @players, ((prev, player) -> prev + player.calc.partyScore()), 0

  getPartyName: ->
    if @players.length > 1 then @name else @players[0].name

  pickPartyName: ->
    return "The Null Party" if not Party::partyGrammar?
    format = _.sample Party::partyGrammar
    return "The Null Party" if not format?
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