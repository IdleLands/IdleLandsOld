

PlayerManager = require "./PlayerManager"
EventHandler = require "./EventHandler"
MonsterManager = require "./MonsterManager"
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"

console.log "Rebooted IdleLands"

class Game

  #Constants either go here, or in a Constants class

  constructor: () ->
    @playerManager = new PlayerManager @
    @monsterManager = new MonsterManager()
    @eventHandler = new EventHandler()

  registerBroadcastHandler: (@broadcastHandler, @broadcastContext) ->
    console.log "Registered broadcast handler."
    @broadcast MessageCreator.generateMessage "Initializing the Lands that Idle (#{Constants.gameName})."

  broadcast: (message) ->
    return if not message
    if @broadcastHandler
      (@broadcastHandler.bind @broadcastContext, message)()
    else
      console.error "No broadcast handler registered. Cannot send: #{message}"

  nextAction: (identifier) ->

module.exports = exports = Game