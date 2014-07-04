

PlayerManager = require "./PlayerManager"
EventHandler = require "./EventHandler"
MonsterManager = require "./MonsterManager"
MessageCreator = require "./MessageCreator"
ComponentDatabase = require "./ComponentDatabase"
EquipmentGenerator = require "./EquipmentGenerator"
Constants = require "./Constants"
GMCommands = require "./GMCommands"
Party = require "../event/Party"
World = require "../map/World"

_ = require "underscore"
chance = (new require "Chance")()

console.log "Rebooted IdleLands."

class Game

  #Constants either go here, or in a Constants class

  constructor: () ->
    @playerManager = new PlayerManager @
    @monsterManager = new MonsterManager()
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

    partyAdditionSize = Math.min (players.length / 2), chance.integer {min: 1, max: Constants.defaults.maxPartySize}
    newPartyPlayers = _.sample (_.reject players, (player) -> player.party), partyAdditionSize

    return if newPartyPlayers.length is 0

    partyPlayers = [player].concat newPartyPlayers

    new Party @, partyPlayers

  teleport: (player, map, x, y, text) ->
    player.map = map
    player.x = x
    player.y = y
    @broadcast MessageCreator.genericMessage text

  nextAction: (identifier) ->
    @playerManager.playerTakeTurn identifier

module.exports = exports = Game