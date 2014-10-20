
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
      defer = @gameInstance.nextAction identifier
      defer.promise

    gender: (identifier, newGender) =>
      defer = @gameInstance.playerManager.getPlayerById(identifier)?.setGender newGender
      defer.promise

    auth:
      register: (options) =>
        defer = @gameInstance.playerManager.registerPlayer options
        defer.promise

      login: (identifier, suppress) =>
        defer = @gameInstance.playerManager.addPlayer identifier, suppress
        defer.promise

      logout: (identifier) =>
        defer = @gameInstance.playerManager.removePlayer identifier
        defer.promise

    overflow:
      add: (identifier, slot) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.manageOverflow "add", slot
        defer.promise

      sell: (identifier, slot) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.manageOverflow "sell", slot
        defer.promise

      swap: (identifier, slot) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.manageOverflow "swap", slot
        defer.promise

    personality:
      add: (identifier, personality) =>
        console.log @gameInstance.playerManager.getPlayerById(identifier), identifier
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.addPersonality personality
        defer.promise

      remove: (identifier, personality) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.removePersonality personality
        defer.promise

    pushbullet:
      add: (identifier, apiKey) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.setPushbulletKey apiKey
        defer.promise

      remove: (identifier) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.setPushbulletKey ''
        defer.promise

    string:
      add: (identifier, stringType, string) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.setString stringType, string
        defer.promise

      remove: (identifier, stringType) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.setString stringType
        defer.promise

module.exports = exports = API