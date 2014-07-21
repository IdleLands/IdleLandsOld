

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
    @playerManager = new PlayerManager @
    @monsterManager = new MonsterManager()
    @spellManager = new SpellManager @
    @eventHandler = new EventHandler @
    @equipmentGenerator = new EquipmentGenerator @
    @componentDatabase = new ComponentDatabase @
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
    return if parties.length < 2 and @parties.length < 2 and @playerManager.players.length < 2

    if parties.length is 0 and @parties.length < 2 and chance.bool {likelihood: 50}
      potentialPlayers = _.sample (_.reject @playerManager.players, (player) -> player.party), 2
      return if potentialPlayers.length < 2
      parties = [ (new Party @, potentialPlayers[0]), (new Party @, potentialPlayers[1])]

    else
      potentialParties = _.sample @parties, 2
      return if potentialParties.length < 2
      parties = potentialParties

    party1score = parties[0].score()
    party2score = parties[1].score()

    minScore = Math.min party1score, party2score
    maxScore = Math.max party1score, party2Score

    maxPercDiff = Constants.defaults.game.maxPartyScorePercentDifference

    if minScore < maxScore*maxPercDiff
      @broadcast MessageCreator.genericMessage "#{parties[0].getName()} passed by #{parties[1].getName()}, smiling and waving."
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