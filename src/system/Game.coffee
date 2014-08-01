

PlayerManager = require "./PlayerManager"
EventHandler = require "./EventHandler"
MonsterManager = require "./MonsterManager"
MessageCreator = require "./MessageCreator"
ComponentDatabase = require "./ComponentDatabase"
EquipmentGenerator = require "./EquipmentGenerator"
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

  #Constants either go here, or in a Constants class

  constructor: () ->
    @parties = []
    @componentDatabase = new ComponentDatabase @
    @playerManager = new PlayerManager @
    @monsterManager = new MonsterManager()
    @spellManager = new SpellManager @
    @eventHandler = new EventHandler @
    @equipmentGenerator = new EquipmentGenerator @
    @gmCommands = new GMCommands @
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

    if parties.length is 0
      # Calculate number of teams involved
      # TODO: Randomize number of teams
      numberOfTeams = 2
      return if numberOfTeams > @playerManager.players.length

      # Calculate how many players will participate in the battle
      # TODO: Skew chances so that smaller teams are chosen more often
      maxParticipants = Constants.defaults.game.maxPartyMembers * numberOfTeams
      numParticipants = chance.integer({min: numberOfTeams, max: maxParticipants})

      # Determine pool of eligible candidates
      soloPlayers = _.reject @playerManager.players, (player) -> player.party
      candidates = @parties.concat soloPlayers
      return if numberOfTeams > candidates.length

      # Choose randomly the participants for this battle
      # TODO: Skip parties that would bring us over the decided max participants
      participants = []
      candidates = _.shuffle candidates
      while candidates.length > 0 and participants.length < numParticipants
        participants.push candidates.pop()

      # Split evenly (discriminate on score) the participants into parties
      groups = []
      for i in [0...numberOfTeams]
        groups[i] = []
        groups[i].score = () -> _.reduce this, ((sum, current) -> sum += current.score()), 0

      # TODO: Support multiple parties
      participants = _.sortBy participants, (c) -> c.score()
      while participants.length > 0
        if groups[0].score() < groups[1].score()
          groups[0].push participants.pop()
        else
          groups[1].push participants.pop()

      # Merge groups
      collapseGroup = (group) ->
        masterParty = _.sample _.filter group, (party) -> party instanceof Party
        if masterParty
          otherParties = _.sample _.filter group, (party) -> party instanceof Party and party isnt masterParty
          _.each otherParties, (party) ->
            members = party.disband?()
            masterParty.recruit members
          masterParty
        else
          new Party @, group

      for i in [0...numberOfTeams]
        parties[i] = collapseGroup(groups[i])
    else
      potentialParties = _.sample @parties, 2
      return if potentialParties.length < 2
      parties = potentialParties

    # TODO: Support multiple parties
    party1score = parties[0].score()
    party2score = parties[1].score()

    minScore = Math.min party1score, party2score
    maxScore = Math.max party1score, party2score

    playerLists = _.map parties, (party) -> _.map party.players, (player) -> player.name
    if (_.intersection playerLists...).length > 1
      console.error "ERROR: BATTLE FORMATION BLOCKED DUE TO ONE PLAYER BEING ON BOTH SIDES"
      return

    maxPercDiff = Constants.defaults.game.maxPartyScorePercentDifference

    if minScore < maxScore*maxPercDiff
      @broadcast MessageCreator.genericMessage "#{parties[0].getPartyName()} passed by #{parties[1].getPartyName()}, smiling and waving."
      return

    if event
      @broadcast MessageCreator.genericMessage MessageCreator.doStringReplace event.remark, event.player

    @inBattle = true
    new Battle @,parties

  teleport: (player, map, x, y, text) ->
    player.map = map
    player.x = x
    player.y = y
    @broadcast MessageCreator.genericMessage text

  nextAction: (identifier) ->
    @playerManager.playerTakeTurn identifier

module.exports = exports = Game
