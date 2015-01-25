
Q = require "q"

class API

  @gameInstance: null

  @validateIdentifier: (identifier) ->
    defer = Q.defer()
    player = @gameInstance.playerManager.getPlayerById identifier

    defer.resolve {isSuccess: yes, code: 999999, player: player} if player #lol
    defer.resolve {isSuccess: no, code: 10, message: "You aren't logged in!"}

    defer.promise

  @validateContentModerator: (identifier) ->
    defer = Q.defer()
    player = @gameInstance.playerManager.getPlayerById identifier

    defer.resolve {isSuccess: no, code: 510, message: "You aren't a content moderator!"} if not player?.isContentModerator
    defer.resolve {isSuccess: yes, code: 999999, player: player} if player #lol
    defer.resolve {isSuccess: no, code: 10, message: "You aren't logged in!"}

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
    content:
      map: (mapName) =>
        @gameInstance.world.maps[mapName].getMapData()
      battle: (battleId) =>
        @gameInstance.componentDatabase.retrieveBattle battleId

  # Invoked manually to either update or mess with the game
  @gm =
    custom:
      init: =>
        @gameInstance.gmCommands.initializeCustomData()

      update: =>
        @gameInstance.gmCommands.updateCustomData()

      list: (identifier) =>
        @validateContentModerator identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.componentDatabase.getContentList() else res

      approve: (identifier, ids) =>
        @validateContentModerator identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.componentDatabase.approveContent ids else res

      reject: (identifier, ids) =>
        @validateContentModerator identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.componentDatabase.rejectContent ids else res

      modModerator: (newModeratorIdentifier, isModerator = yes) =>
        @gameInstance.gmCommands.setModeratorStatus newModeratorIdentifier, isModerator

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
      setPassword: (identifier, password) =>
        @gameInstance.playerManager.storePasswordFor identifier, password

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

      giveGold: (playerName, gold) =>
        player = @gameInstance.playerManager.getPlayerByName playerName
        player.gold.add gold

    arrangeBattle: (names) =>
      @gameInstance.gmCommands.arrangeBattle names

  # Invoked either automatically (by means of taking a turn), or when a player issues a command
  @player =
    takeTurn: (identifier, sendPlayerObject = yes) =>
      @validateIdentifier identifier
      .then (res) =>
        if res.isSuccess then @gameInstance.playerManager.playerTakeTurn identifier, sendPlayerObject else res

    action:
      teleport: (identifier, newLoc) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.manualTeleportToLocation newLoc else res

    custom:
      submit: (identifier, data) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.componentDatabase.submitCustomContent identifier, data else res

    gender:
      set: (identifier, newGender) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.setGender newGender else res

      remove: (identifier) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.setGender '' else res

    auth:
      register: (options) =>
        @gameInstance.playerManager.registerPlayer options

      login: (identifier, suppress) =>
        @gameInstance.playerManager.addPlayer identifier, suppress, no

      loginWithPassword: (identifier, password) =>
        @gameInstance.playerManager.loginWithPassword identifier, password

      setPassword: (identifier, password) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.playerManager.storePasswordFor identifier, password else res

      authenticate: (identifier, password) =>
        @gameInstance.playerManager.checkPassword identifier, password, yes

      logout: (identifier) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.playerManager.removePlayer identifier else res

      isTokenValid: (identifier, token) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.playerManager.checkToken identifier, token else res

    overflow:
      add: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.manageOverflow "add", slot else res

      sell: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.manageOverflow "sell", slot else res

      swap: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.manageOverflow "swap", slot else res

    personality:
      add: (identifier, personality) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.addPersonality personality else res

      remove: (identifier, personality) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.removePersonality personality else res

    priority:
      add: (identifier, stat, points) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.addPriority stat, points else res

      set: (identifier, stats) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.setPriorities stats else res

      remove: (identifier, stat, points) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.addPriority stat, -points else res

    pushbullet:
      set: (identifier, apiKey) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.setPushbulletKey apiKey else res

      remove: (identifier) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.setPushbulletKey '' else res

    title:
      set: (identifier, newTitle) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.setTitle newTitle else res

    string:
      set: (identifier, stringType, string) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.setString stringType, string else res

      remove: (identifier, stringType) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.setString stringType else res

    pet:
      buy: (identifier, type, name, attr1, attr2) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.buyPet type, name, attr1, attr2 else res

      upgrade: (identifier, stat) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.upgradePet stat else res

      feed: (identifier) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.feedPet() else res

      takeGold: (identifier) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.takePetGold() else res

      giveEquipment: (identifier, itemSlot) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.givePetItem itemSlot else res

      sellEquipment: (identifier, itemSlot) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.sellPetItem itemSlot else res

      takeEquipment: (identifier, itemSlot) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.takePetItem itemSlot else res

      equipItem: (identifier, itemSlot) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.equipPetItem itemSlot else res

      unequipItem: (identifier, itemUid) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.unequipPetItem itemUid else res

      setOption: (identifier, option, value) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.setPetOption option, value else res

      swapToPet: (identifier, petId) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.swapToPet petId else res

      changeClass: (identifier, petClass) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.changePetClass petClass else res

    guild:
      create: (identifier, guildName) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.guildManager.createGuild identifier, guildName else res

      invite: (identifier, invName) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.guildManager.sendInvite identifier, invName else res

      manageInvite: (identifier, accepted, guildName) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.guildManager.manageInvite identifier, accepted, guildName else res

      promote: (identifier, memberName) =>
        @validateIdentifier identifier
        .then (res) =>
          guild = res.player.guild
          if res.isSuccess then @gameInstance.guildManager.guildHash[guild].promote identifier, memberName else res

      demote: (identifier, memberName) =>
        @validateIdentifier identifier
        .then (res) =>
          guild = res.player.guild
          if res.isSuccess then @gameInstance.guildManager.guildHash[guild].demote identifier, memberName else res

      kick: (identifier, playerName) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.guildManager.kickPlayer identifier, playerName else res

      disband: (identifier) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.guildManager.disband identifier else res

      leave: (identifier) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.guildManager.leaveGuild identifier else res

      donate: (identifier, gold) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.guildManager.donate identifier, gold else res

      buff: (identifier, type, tier) =>
        @validateIdentifier identifier
        .then (res) =>
          if res.isSuccess then @gameInstance.guildManager.addBuff identifier, type, tier else res

      tax:
        whole: (identifier, taxPercent) =>
          @validateIdentifier identifier
          .then (res) =>
            guild = res.player.guild
            if res.isSuccess then @gameInstance.guildManager.guildHash[guild].setTax identifier, taxPercent else res

        self: (identifier, taxPercent) =>
          @validateIdentifier identifier
          .then (res) =>
            if res.isSuccess then res.player.setSelfGuildTax taxPercent else res

    shop:
      buy: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          if res.isSuccess then res.player.buyShop slot else res
      
module.exports = exports = API