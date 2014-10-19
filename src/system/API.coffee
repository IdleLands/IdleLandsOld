
q = require "q"

class API

  @gameInstance: null

  # Called on game initialization
  @game =
    handlers:
      broadcastHandler: (handler, context) =>
        @gameInstance.registerBroadcastHandler handler, context
      colorMap: (map) =>
        @gameInstance.registerColors map
      playerLoadHandler: (handler) =>
        @gameInstance.playerManager.registerLoadAllPlayersHandler handler

  # Invoked manually to either update or mess with the game
  @gm =
    teleport:
      location:
        single: (playerName, location) =>
          player = @gameInstance.playerManager.getPlayerByName playerName
          @gameInstance.gmCommands.teleportLocation player, location
          null
        mass: (location) =>
          @gameInstance.gmCommands.massTeleportLocation location
          null
      map:
        single: (playerName, map, x, y) =>
          player = @gameInstance.playerManager.getPlayerByName playerName
          @gameInstance.gmCommands.teleport player, map, x, y
          null
        mass: (map, x, y) =>
          @gameInstance.gmCommands.massTeleport map, x, y
          null

    data:
      update: =>
        @gameInstance.doCodeUpdate()
      reload: =>
        @gameInstance.componentDatabase.importAllData()

    event:
      single: (player, eventType, callback) =>
        @gameInstance.eventHandler.doEventForPlayer player, eventType, callback
      global: (eventType, callback) =>
        @gameInstance.globalEventHandler.doEvent eventType, callback

    status:
      ban: (name, callback) =>
        @gameInstance.playerManager.banPlayer name, callback
      unban: (name, callback) =>
        @gameInstance.playerManager.unbanPlayer name, callback

  # Invoked either automatically (by means of taking a turn), or when a player issues a command
  @player =
    nextAction: (identifier) =>
      @gameInstance.nextAction identifier

    gender: (identifier, newGender) =>
      @gameInstance.playerManager.getPlayerById(identifier)?.setGender newGender

    auth:
      register: (options, middleware, callback) =>
        @gameInstance.playerManager.registerPlayer options, middleware, callback
      login: (identifier, suppress) =>
        @gameInstance.playerManager.addPlayer identifier, suppress
      logout: (identifier) =>
        @gameInstance.playerManager.removePlayer identifier

    personality:
      add: (identifier, personality) =>
        @gameInstance.playerManager.getPlayerById(identifier)?.addPersonality personality
      remove: (identifier, personality) =>
        @gameInstance.playerManager.getPlayerById(identifier)?.removePersonality personality

    string:
      add: (identifier, stringType, string) =>
        @gameInstance.playerManager.getPlayerById(identifier)?.setString stringType, string
      remove: (identifier, stringType) =>
        @gameInstance.playerManager.getPlayerById(identifier)?.setString stringType

    pushbullet:
      add: (identifier, apiKey) =>
        @gameInstance.playerManager.getPlayerById(identifier)?.setPushbulletKey apiKey
      remove: (identifier) =>
        @gameInstance.playerManager.getPlayerById(identifier)?.setPushbulletKey ''

    overflow:
      add: (identifier, slot) =>
        @gameInstance.playerManager.getPlayerById(identifier)?.manageOverflow "add", slot
      remove: (identifier, slot) =>
        @gameInstance.playerManager.getPlayerById(identifier)?.manageOverflow "sell", slot
      swap: (identifier, slot) =>
        @gameInstance.playerManager.getPlayerById(identifier)?.manageOverflow "swap", slot

module.exports = exports = API