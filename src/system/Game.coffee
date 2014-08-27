

PlayerManager = require "./PlayerManager"
EventHandler = require "./EventHandler"
MonsterGenerator = require "./MonsterGenerator"
MessageCreator = require "./MessageCreator"
ComponentDatabase = require "./ComponentDatabase"
EquipmentGenerator = require "./EquipmentGenerator"
GlobalEventHandler = require "./GlobalEventHandler"
SpellManager = require "./SpellManager"
Constants = require "./Constants"
GMCommands = require "./GMCommands"
Party = require "../event/Party"
Battle = require "../event/Battle"
World = require "../map/World"

_ = require "underscore"
chance = (new require "chance")()

console.log "Rebooted IdleLands."

class Game

  constructor: () ->
    @parties = []
    @gmCommands = new GMCommands @
    @spellManager = new SpellManager @
    @eventHandler = new EventHandler @
    @playerManager = new PlayerManager @
    @monsterGenerator = new MonsterGenerator @
    @componentDatabase = new ComponentDatabase @
    @globalEventHandler = new GlobalEventHandler @
    @equipmentGenerator = new EquipmentGenerator @
    @world = new World()

  registerBroadcastHandler: (@broadcastHandler, @broadcastContext) ->
    console.info "Registered broadcast handler."
    @broadcast MessageCreator.generateMessage "Initializing the Lands that Idle (#{Constants.gameName})."

  broadcast: (message) ->
    return if not message
    if @broadcastHandler
      (@broadcastHandler.bind @broadcastContext, message)()
    else
      console.error "No broadcast handler registered. Cannot send: #{message}"

  createParty: (player) ->
    players = _.without @playerManager.players, player

    partyAdditionSize = Math.min (players.length / 2), chance.integer({min: 1, max: Constants.defaults.game.maxPartyMembers})
    newPartyPlayers = _.sample (_.reject players, (player) -> player.party), partyAdditionSize

    return if newPartyPlayers.length is 0

    partyPlayers = [player].concat newPartyPlayers

    new Party @, partyPlayers

  startBattle: (parties = [], event = null) ->
    return if @inBattle
    return if parties.length < 2 and @playerManager.players.length < 2

    startBattle = (parties) =>

      if event
        @broadcast MessageCreator.genericMessage MessageCreator.doStringReplace event.remark, event.player

      @inBattle = true
      new Battle @,parties

    tryBattle = (parties) =>
      return if parties.length is 0

      partyScores = _.map parties, (party) -> party.score()

      minScore = Math.min partyScores...
      maxScore = Math.max partyScores...

      playerLists = _.map parties, (party) -> _.map party.players, (player) -> player.name
      modified = _.flatten playerLists
      if (_.uniq modified).length < modified.length
        console.error "ERROR: BATTLE FORMATION BLOCKED DUE TO ONE PLAYER BEING ON BOTH SIDES"
        return no

      maxPercDiff = Constants.defaults.game.maxPartyScorePercentDifference

      if minScore < maxScore*maxPercDiff
        @broadcast MessageCreator.genericMessage "#{parties[0].getPartyName()} passed by #{parties[1].getPartyName()}, smiling and waving."
        _.each parties, (party) -> party.disband()
        return no

      return no if parties.length is 0

      yes

    group = _.sample parties, 2
    if tryBattle group
      startBattle group
      return

    # player ordering
    soloPlayers = _.reject @playerManager.players, (player) -> player.party
    soloPlayersOrdered = _.sortBy soloPlayers, (player) -> -player.calc.totalItemScore()

    # constants
    maxParties = Constants.defaults.game.maxParties
    maxPartyMembers = Constants.defaults.game.maxPartyMembers
    numberOfTeams = 2

    # party generation variables
    buckets = @parties or []
    isSoloBattle = chance.bool likelihood: Constants.defaults.game.soloBattleProbability
    numberOfTeams = chance.integer({min: 3, max: maxParties}) if chance.bool likelihood: Constants.defaults.game.aboveAveragePartyCountBattleProbability
    maxPlayersPerTeam = if isSoloBattle then 1 else maxPartyMembers

    playerArrayToScores = (players) ->
      _.map players, (player) -> player.calc.totalItemScore()

    createParties = (givenPlayers, existingParties, partyMax = 2, perPartyMax = 1) =>

      updatePartySize = (party) ->
        canPartiesTakeMoreMembers[party.name] = no if party.players.length is perPartyMax

      arrayStartPos = soloPlayersOrdered.length - partyMax - 1
      availablePlayers = givenPlayers
      maxPartyScore = (_.max existingParties, (party) -> party.score()).score?()

      if arrayStartPos > 1
        startIndex = chance.integer min: 0, max: arrayStartPos

        firstPlayers = givenPlayers[startIndex..startIndex+partyMax]

        availablePlayers = _.without availablePlayers, firstPlayers...

        maxPartyScore = _.reduce (playerArrayToScores firstPlayers), ((prev, score) -> prev+score), 0

      partyScores = {}
      canPartiesTakeMoreMembers = {}
      partyNames = {}
      partiesAvailable = []

      # add a party to the roster list
      addPartyToRoster = (party) ->
        partyName = party.name
        partyScores[partyName] = party.score()
        canPartiesTakeMoreMembers[partyName] = yes
        partyNames[partyName] = party
        partiesAvailable.push party

        updatePartySize party

      destroyParty = (party) ->
        partyName = party.name
        delete partyScores[partyName]
        delete partyNames[partyName]
        delete canPartiesTakeMoreMembers[partyName]
        party.disband()

      #check if existing parties are below the max score (add to party hash if so)
      _.each existingParties, (existingBucket) ->
        addPartyToRoster existingBucket if existingBucket.score() <= maxPartyScore

      partiesChoosePlayer = ->
        for partyName, score of partyScores
          continue if not canPartiesTakeMoreMembers[partyName]

          choosablePlayers = _.reject availablePlayers, (player) -> player.calc.totalItemScore() > maxPartyScore-score

          if choosablePlayers.length > 0

            party = partyNames[partyName]

            chosenPlayer = _.max choosablePlayers, (player) -> player.calc.totalItemScore()
            availablePlayers = _.without availablePlayers, chosenPlayer
            partyScores[partyName] += chosenPlayer.calc.totalItemScore()

            party.addPlayer chosenPlayer

            updatePartySize party
          else
            canPartiesTakeMoreMembers[partyName] = no

      _.each firstPlayers, (player) =>
        newParty = new Party @, player
        addPartyToRoster newParty

      parties = _.sample partiesAvailable, partyMax

      unusedParties = _.difference partiesAvailable, parties

      _.each unusedParties, destroyParty

      do partiesChoosePlayer for x in [0..availablePlayers.length]

    createParties soloPlayersOrdered, buckets, numberOfTeams, maxPlayersPerTeam

    startBattle parties if tryBattle parties

  teleport: (player, map, x, y, text) ->
    player.map = map
    player.x = x
    player.y = y
    @broadcast MessageCreator.genericMessage text

  nextAction: (identifier) ->
    @playerManager.playerTakeTurn identifier

  doCodeUpdate: ->
    require("git-pull") "../", (e, consoleOutput) ->
      console.error e if e
      console.log consoleOutput
      process.exit 0

module.exports = exports = Game
