
Q = require "q"

class API

  @gameInstance: null

  @validateIdentifier: (identifier) ->
    defer = Q.defer()
    player = @gameInstance.playerManager.getPlayerById identifier

    defer.resolve {isSuccess: yes, player: player}
    defer.resolve {isSuccess: no, message: "You aren't logged in!"}

    defer.promise

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
      @validateIdentifier identifier
      .then (res) =>
        @gameInstance.nextAction identifier if res.isSuccess

    gender: (identifier, newGender) =>
      @validateIdentifier identifier
      .then (res) ->
        res.player.setGender newGender if res.isSuccess

    auth:
      register: (options) =>
        @gameInstance.playerManager.registerPlayer options

      login: (identifier, suppress) =>
        @validateIdentifier identifier
        .then (res) =>
          (@gameInstance.playerManager.addPlayer identifier, suppress, no) if res.isSuccess
          else res

      loginWithPassword: (identifier, password) =>
        @validateIdentifier identifier
        .then (res) =>
          @gameInstance.playerManager.loginWithPassword identifier, password if res.isSuccess
          else res

      setPassword: (identifier, password) =>
        @validateIdentifier identifier
        .then (res) =>
          @gameInstance.playerManager.storePasswordFor identifier, password if res.isSuccess
          else res

      authenticate: (identifier, password) =>
        @validateIdentifier identifier
        .then (res) =>
          (@gameInstance.playerManager.checkPassword identifier, password, yes) if res.isSuccess
          else res

      logout: (identifier) =>
        @validateIdentifier identifier
        .then (res) =>
          @gameInstance.playerManager.removePlayer identifier if res.isSuccess
          else res

      isTokenValid: (identifier, token) =>
        @validateIdentifier identifier
        .then (res) =>
          @gameInstance.playerManager.checkToken identifier, token if res.isSuccess
          else res

    overflow:
      add: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          res.player.manageOverflow "add", slot if res.isSuccess

      sell: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          res.player.manageOverflow "sell", slot if res.isSuccess

      swap: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          res.player.manageOverflow "swap", slot if res.isSuccess

    personality:
      add: (identifier, personality) =>
        @validateIdentifier identifier
        .then (res) ->
          res.player.addPersonality personality if res.isSuccess

      remove: (identifier, personality) =>
        @validateIdentifier identifier
        .then (res) ->
          res.player.removePersonality personality if res.isSuccess

    pushbullet:
      set: (identifier, apiKey) =>
        @validateIdentifier identifier
        .then (res) ->
          res.player.setPushbulletKey apiKey if res.isSuccess

      remove: (identifier) =>
        @validateIdentifier identifier
        .then (res) ->
          res.player.setPushbulletKey '' if res.isSuccess

    string:
      set: (identifier, stringType, string) =>
        @validateIdentifier identifier
        .then (res) ->
          res.player.setString stringType, string if res.isSuccess

      remove: (identifier, stringType) =>
        @validateIdentifier identifier
        .then (res) ->
          res.player.setString stringType if res.isSuccess

    guild:
      create: (identifier, guildName) =>
        @validateIdentifier identifier
        .then (res) =>
          @gameInstance.guildManager.createGuild identifier, guildName if res.isSuccess

      invite: (identifier, invName) =>
        @validateIdentifier identifier
        .then (res) =>
          @gameInstance.guildManager.sendInvite identifier, invName if res.isSuccess

      manageInvite: (identifier, accepted, guildName) =>
        @validateIdentifier identifier
        .then (res) =>
          @gameInstance.guildManager.manageInvite identifier, accepted, guildName if res.isSuccess

      promote: (identifier, memberName) =>
        @validateIdentifier identifier
        .then (res) =>
          return if not res.isSuccess
          guild = res.player.guild
          @gameInstance.guildManager.guildHash[guild].promote identifier, memberName if res.isSuccess

      demote: (identifier, memberName) =>
        @validateIdentifier identifier
        .then (res) =>
          return if not res.isSuccess
          guild = res.player.guild
          @gameInstance.guildManager.guildHash[guild].demote identifier, memberName if res.isSuccess

      kick: (identifier, playerName) =>
        @validateIdentifier identifier
        .then (res) =>
          @gameInstance.guildManager.kickPlayer identifier, playerName if res.isSuccess

      disband: (identifier) =>
        @validateIdentifier identifier
        .then (res) =>
          @gameInstance.guildManager.disband identifier if res.isSuccess

      leave: (identifier) =>
        @validateIdentifier identifier
        .then (res) =>
          @gameInstance.guildManager.leaveGuild identifier if res.isSuccess

module.exports = exports = API