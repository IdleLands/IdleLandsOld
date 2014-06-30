
class API

  @gameInstance: null

  #getGender for a player
  #get Coins for a player (coins are special currency, not like the in-game gold)

  @registerPlayer: (options, middleware, callback) ->
    @gameInstance.playerManager.registerPlayer options, middleware, callback

  @addManyPlayers: (identifiers) ->
    identifiers.forEach (identifier) =>
      @addPlayer identifier

  @addPlayer: (identifier) ->
    @gameInstance.playerManager.addPlayer identifier

  @removePlayer: (identifier) ->
    @gameInstance.playerManager.removePlayer identifier

  @registerBroadcastHandler: (handler, context) ->
    @gameInstance.registerBroadcastHandler handler, context

  @registerPlayerLoadHandler: (handler) ->
    @gameInstance.playerManager.registerLoadAllPlayersHandler handler

  @nextAction: (identifier) ->
    @gameInstance.nextAction identifier

  @add =
    yesno: (question, y, n) =>
      @gameInstance.componentDatabase.insertYesNo question, y, n
    static: (eventType, remark) =>
      @gameInstance.componentDatabase.insertStatic eventType, remark
    item: (item, duplicateCallback) =>
      @gameInstance.componentDatabase.insertItem item, duplicateCallback

  @find: (query, callback) ->
    @gameInstance.componentDatabase.findEvent query, callback

  @remove: (id, callback) ->
    @gameInstance.componentDatabase.removeEvent id, callback

  @teleport =
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

module.exports = exports = API