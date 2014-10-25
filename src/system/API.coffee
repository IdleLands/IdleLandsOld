
q = require "q"

notLoggedIn = ->
  defer = q.defer()
  defer.resolve {isSuccess: no, message: "You aren't logged in!"}
  defer.promise

pickValidPromise = (test) ->
  test ?= notLoggedIn()

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

    player:
      createItem: (playerName, type, itemString) =>
        player = @gameInstance.playerManager.getPlayerByName playerName
        @gameInstance.gmCommands.createItemFor player, type, itemString

  # Invoked either automatically (by means of taking a turn), or when a player issues a command
  @player =
    nextAction: (identifier) =>
      defer = @gameInstance.nextAction identifier
      pickValidPromise defer?.promise

    gender: (identifier, newGender) =>
      defer = @gameInstance.playerManager.getPlayerById(identifier)?.setGender newGender
      pickValidPromise defer?.promise

    auth:
      register: (options) =>
        defer = @gameInstance.playerManager.registerPlayer options
        pickValidPromise defer?.promise

      login: (identifier, suppress) =>
        defer = @gameInstance.playerManager.addPlayer identifier, suppress
        pickValidPromise defer?.promise

      loginWithPassword: (identifier, password, suppress) =>

      createPassword: (identifier, password) =>
        defer = @gameInstance.playerManager.storePasswordFor identifier, password
        pickValidPromise defer?.promise

      authenticate: (identifier, password) =>
        defer = @gameInstance.playerManager.checkOnlyPassword identifier, password
        pickValidPromise defer?.promise

      logout: (identifier) =>
        defer = @gameInstance.playerManager.removePlayer identifier
        pickValidPromise defer?.promise

    overflow:
      add: (identifier, slot) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.manageOverflow "add", slot
        pickValidPromise defer?.promise

      sell: (identifier, slot) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.manageOverflow "sell", slot
        pickValidPromise defer?.promise

      swap: (identifier, slot) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.manageOverflow "swap", slot
        pickValidPromise defer?.promise

    personality:
      add: (identifier, personality) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.addPersonality personality
        pickValidPromise defer?.promise

      remove: (identifier, personality) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.removePersonality personality
        pickValidPromise defer?.promise

    pushbullet:
      set: (identifier, apiKey) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.setPushbulletKey apiKey
        pickValidPromise defer?.promise

      remove: (identifier) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.setPushbulletKey ''
        pickValidPromise defer?.promise

    string:
      add: (identifier, stringType, string) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.setString stringType, string
        pickValidPromise defer?.promise

      remove: (identifier, stringType) =>
        defer = @gameInstance.playerManager.getPlayerById(identifier)?.setString stringType
        pickValidPromise defer?.promise

    guild:
      create: (identifier, guildName) =>
        defer = @gameInstance.guildManager.createGuild identifier, guildName
        pickValidPromise defer?.promise

      invite: (sendId, invName) =>
        defer = @gameInstance.guildManager.sendInvite sendId, invName
        pickValidPromise defer?.promise

      manageInvite: (invId, accepted, guildName) =>
        defer = @gameInstance.guildManager.manageInvite invId, accepted, guildName
        pickValidPromise defer?.promise

      promote: (leaderId, memberName) =>
        guild = (@gameInstance.playerManager.getPlayerById leaderId).guild
        defer = @gameInstance.guildManager.guildHash[guild].promote leaderId, memberName
        pickValidPromise defer?.promise

      demote: (leaderId, memberName) =>
        guild = (@gameInstance.playerManager.getPlayerById leaderId).guild
        defer = @gameInstance.guildManager.guildHash[guild].demote leaderId, memberName
        pickValidPromise defer?.promise

      kick: (adminId, playerName) =>
        defer = @gameInstance.guildManager.kickPlayer adminId, playerName
        pickValidPromise defer?.promise

      disband: (identifier) =>
        defer = @gameInstance.guildManager.disband identifier
        pickValidPromise defer?.promise

      leave: (identifier) =>
        defer = @gameInstance.guildManager.leaveGuild identifier
        pickValidPromise defer?.promise

module.exports = exports = API