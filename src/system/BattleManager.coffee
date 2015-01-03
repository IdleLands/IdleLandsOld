
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"
Battle = require "../event/Battle"
_ = require "lodash"
chance = (new require "chance")()

class BattleManager
  constructor: (@game) ->

  # sometimes we just need parties formed
  silentlyCreatePlayerParties: (num = 1) ->
    return if num <= 0
    @game.createParty() while num-- > 0

  # return all possible N-grams of the global party list
  getAllPossiblePartyOrderingsInOrder: (sizeLimit = 2) ->
    _(@game.parties)
      .sortBy (party) -> party.score()
      .map (party, index) => @game.parties.slice index, index+sizeLimit
      .reject (arr) -> arr.length isnt sizeLimit
      .value()

  # Pick the best ordering of parties for combat so they're not too far apart
  # Does not prevent roflstomping, but also will never throw errors like the old version
  chooseBestPvPParties: ->
    partiesToChoose = Math.max 2, Math.min Constants.defaults.game.maxParties, @game.parties.length
    partiesToCreate = Math.max 0, partiesToChoose - @game.parties.length
    @silentlyCreatePlayerParties partiesToCreate

    partyCombinations = @getAllPossiblePartyOrderingsInOrder()

    sortedPartyCombos = _.sortBy partyCombinations, (partyArray) ->
      partyArray[partyArray.length-1].score() - partyArray[0].score()

    sortedPartyCombos[0]

  # this is just a function extracted from startBattle that actually starts the battle
  _startBattle: (parties, event) ->
    @game._battleParties = parties

    @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace event.remark, event.player if event

    @game.inBattle = true

    new Battle @game, parties
    null

  # this function sets up parties for combat, it's a transformation function essentially
  # 0 parties = PvP battle
  # 1 party = monster battle
  startBattle: (parties = [], event = null) ->
    return if @inBattle
    return if parties.length < 2 and @game.playerManager.players.length < 2

    # no parties = global event = pvp battle
    if parties.length is 0
      parties = @chooseBestPvPParties()
      _.each parties, (party) -> party.prepareForBattle()

    # 1 party = monster battle
    else if parties.length is 1
      parties[0].prepareForBattle()
      try
        parties.push @game.monsterGenerator.experimentalMonsterPartyGeneration parties[0]
        parties.push @game.monsterGenerator.experimentalMonsterPartyGeneration parties[0] / 1.5 if chance.bool {likelihood: 15} and parties[0].level() < 100
      catch e
        console.error e.stack

    else
      _.each parties, (party) -> party.prepareForBattle()

    @_startBattle parties, event

module.exports = exports = BattleManager