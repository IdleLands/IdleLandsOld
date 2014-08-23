
class API

  @gameInstance: null

  @register =
    player: (options, middleware, callback) =>
      @gameInstance.playerManager.registerPlayer options, middleware, callback

    broadcastHandler: (handler, context) =>
      @gameInstance.registerBroadcastHandler handler, context

    playerLoadHandler: (handler) =>
      @gameInstance.playerManager.registerLoadAllPlayersHandler handler

  @game =
    nextAction: (identifier) =>
      @gameInstance.nextAction identifier

    teleport:
      singleLocation: (playerName, location) =>
        player = @gameInstance.playerManager.getPlayerByName playerName
        @gameInstance.gmCommands.teleportLocation player, location

      single: (playerName, map, x, y) =>
        player = @gameInstance.playerManager.getPlayerByName playerName
        @gameInstance.gmCommands.teleport player, map, x, y

      massLocation: (location) =>
        @gameInstance.gmCommands.massTeleportLocation location

      mass: (map, x, y) =>
        @gameInstance.gmCommands.massTeleport map, x, y

    banPlayer: (name, callback) =>
      @gameInstance.playerManager.banPlayer name, callback

    unbanPlayer: (name, callback) =>
      @gameInstance.playerManager.unbanPlayer name, callback

    doEvent: (player, eventType, callback) =>
      @gameInstance.eventHandler.doEventForPlayer player, callback, eventType

    doGlobalEvent: (eventType, callback) =>
      @gameInstance.globalEventHandler.doEvent eventType, callback

    update: =>

  @add =
    yesno: (question, y, n) =>
      @gameInstance.componentDatabase.insertYesNo question, y, n
    static: (eventType, remark) =>
      @gameInstance.componentDatabase.insertStatic eventType, remark
    item: (item, duplicateCallback) =>
      @gameInstance.componentDatabase.insertItem item, duplicateCallback
    player: (identifier, suppress) =>
      @gameInstance.playerManager.addPlayer identifier, suppress
    personality: (identifier, personality) =>
      @gameInstance.playerManager.getPlayerById(identifier)?.addPersonality personality
    allData: =>
      @gameInstance.componentDatabase.importAllData()

  @find =
    static: (query, callback) =>
      @gameInstance.componentDatabase.findEvent query, callback

  @remove =
    static: (id, callback) =>
      @gameInstance.componentDatabase.removeEvent id, callback
    player: (identifier) =>
      @gameInstance.playerManager.removePlayer identifier
    personality: (identifier, personality) =>
      @gameInstance.playerManager.playerHash[identifier]?.removePersonality personality

module.exports = exports = API