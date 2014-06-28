

PlayerManager = require "./PlayerManager"
EventHandler = require "./EventHandler"
MonsterManager = require "./MonsterManager"
MessageCreator = require "./MessageCreator"
ComponentDatabase = require "./ComponentDatabase"
Constants = require "./Constants"
GMCommands = require "./GMCommands"
World = require "../map/World"

console.log "Rebooted IdleLands."

class Game

  #Constants either go here, or in a Constants class

  constructor: () ->
    @playerManager = new PlayerManager @
    @monsterManager = new MonsterManager()
    @eventHandler = new EventHandler @
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

  teleport: (player, map, x, y, text) ->
    player.map = map
    player.x = x
    player.y = y
    @broadcast MessageCreator.genericMessage text

  nextAction: (identifier) ->
    @playerManager.playerTakeTurn identifier

module.exports = exports = Game