
Q = require "q"

class API

  @gameInstance: null
  @logger: null

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
    events:
      small:  (filterPlayers, newerThan) =>
        @gameInstance.eventHandler.retrieveEvents 10, filterPlayers, newerThan
      medium: (filterPlayers, newerThan) =>
        @gameInstance.eventHandler.retrieveEvents 100, filterPlayers, newerThan
      large:  (filterPlayers, newerThan) =>
        @gameInstance.eventHandler.retrieveEvents 1000, filterPlayers, newerThan

  # Invoked manually to either update or mess with the game
  @gm =
    custom:
      init: =>
        @logger?.debug "GM Command custom.init"
        @gameInstance.gmCommands.initializeCustomData()

      update: =>
        @logger?.debug "GM Command custom.update"
        @gameInstance.gmCommands.updateCustomData()

      list: (identifier) =>
        @validateContentModerator identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.componentDatabase.getContentList() else actualRes = res
          @logger?.debug "GM Command custom.list"
          @logger?.verbose "GM Command custom.list", {res: actualRes}
          actualRes

      approve: (identifier, ids) =>
        @validateContentModerator identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.componentDatabase.approveContent ids else actualRes = res
          @logger?.debug "GM Command custom.approve"
          @logger?.verbose "GM Command custom.approve", {res: actualRes}
          actualRes

      reject: (identifier, ids) =>
        @validateContentModerator identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.componentDatabase.rejectContent ids else actualRes = res
          @logger?.debug "GM Command custom.reject"
          @logger?.verbose "GM Command custom.reject", {res: actualRes}
          actualRes

      modModerator: (newModeratorIdentifier, isModerator = yes) =>
        @logger?.debug "GM Command custom.modModerator",
        @logger?.verbose "GM Command custom.modModerator", {newModeratorIdentifier: newModeratorIdentifier, isModerator: isModerator}
        @gameInstance.gmCommands.setModeratorStatus newModeratorIdentifier, isModerator

    teleport:
      location:
        single: (playerName, location) =>
          player = @gameInstance.playerManager.getPlayerByName playerName
          @logger?.debug "GM Command teleport.location.single"
          @logger?.verbose "GM Command teleport.location.single", {playerName: playerName, location: location, player: player}
          @gameInstance.gmCommands.teleportLocation player, location
          null
        mass: (location) =>
          @logger?.debug "GM Command teleport.location.mass"
          @logger?.verbose "GM Command teleport.location.mass", {location: location}
          @gameInstance.gmCommands.massTeleportLocation location
          null
      map:
        single: (playerName, map, x, y) =>
          player = @gameInstance.playerManager.getPlayerByName playerName
          @logger?.debug "GM Command teleport.map.single"
          @logger?.verbose "GM Command teleport.map.single", {playerName: playerName, map: map, x: x, y: y}
          @gameInstance.gmCommands.teleport player, map, x, y
          null
        mass: (map, x, y) =>
          @logger?.debug "GM Command teleport.map.mass"
          @logger?.verbose "GM Command teleport.map.mass", {map: map, x: x, y: y}
          @gameInstance.gmCommands.massTeleport map, x, y
          null

    data:
      update: =>
        @logger?.debug "GM Command data.update"
        @gameInstance.doCodeUpdate()
      reload: =>
        @logger?.debug "GM Command data.reload"
        @gameInstance.componentDatabase.importAllData()
      setPassword: (identifier, password) =>
        @logger?.debug "GM Command data.setPassword"
        @logger?.verbose "GM Command data.setPassword", {identifier, password: "*******"}
        @gameInstance.playerManager.storePasswordFor identifier, password

    event:
      single: (player, eventType, callback) =>
        @logger?.debug "GM Command event.single"
        @logger?.verbose "GM Command event.single", {player: player, eventType: eventType, callback: callback}
        @gameInstance.eventHandler.doEventForPlayer player, eventType, callback #TODO There are only 2 parameters, callback is ignored?
      global: (eventType, callback) =>
        @logger?.debug "GM Command event.global"
        @logger?.verbose "GM Command event.global", {eventType, callback}
        @gameInstance.globalEventHandler.doEvent eventType, callback

    log:
      setLoggerLevel: (name, level) =>
        @logger?.debug "GM Command log.setLoggerLevel"
        @logger?.verbose "GM Command log.setLoggerLevel", {name, level}
        @gameInstance.logManager.setLoggerLevel name, level

      clearLog: (name) =>
        @logger?.debug "GM Command log.clearLog"
        @logger?.verbose "GM Command log.clearLog", {name}
        @gameInstance.logManager.clearLog name

      clearAllLogs: () =>
        @logger?.debug "GM Command log.clearAllLogs"
        @gameInstance.logManager.clearAllLogs()

    status:
      ban: (name, callback) =>
        @logger?.debug "GM Command status.ban"
        @logger?.verbose "GM Command status.ban", {name, callback}
        @gameInstance.playerManager.banPlayer name, callback
      unban: (name, callback) =>
        @logger?.debug "GM Command status.unban"
        @logger?.verbose "GM Command status.unban", {name, callback}
        @gameInstance.playerManager.unbanPlayer name, callback
      identifierChange: (oldIdent, newIdent) =>
        @logger?.debug "GM Command status.identifierChange"
        @logger?.verbose "GM Command status.identifierChange", {oldIdent, newIdent}
        @gameInstance.gmCommands.changeIdentifier oldIdent, newIdent

    player:
      createItem: (playerName, type, itemString) =>
        player = @gameInstance.playerManager.getPlayerByName playerName
        @logger?.debug "GM Command player.createItem"
        @logger?.verbose "GM Command player.createItem", {playerName, type, itemString, player}
        @gameInstance.gmCommands.createItemFor player, type, itemString

      giveGold: (playerName, gold) =>
        player = @gameInstance.playerManager.getPlayerByName playerName
        @logger?.debug "GM Command player.giveGold"
        @logger?.verbose "GM Command player.giveGold", {playerName, gold, player}
        player.gold.add gold

    arrangeBattle: (names) =>
      @logger?.debug "GM Command arrangeBattle"
      @logger?.verbose "GM Command arrangeBattle", {names}
      @gameInstance.gmCommands.arrangeBattle names

  # Invoked either automatically (by means of taking a turn), or when a player issues a command
  @player =
    takeTurn: (identifier, sendPlayerObject = yes) =>
      @validateIdentifier identifier
      .then (res) =>
        actualRes = null
        if res.isSuccess then actualRes = @gameInstance.playerManager.playerTakeTurn identifier, sendPlayerObject else actualRes = res
        @logger?.debug "Player Command takeTurn"
        @logger?.verbose "Player Command takeTurn", {identifier, sendPlayerObject}
        actualRes

    action:
      teleport: (identifier, newLoc) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.manualTeleportToLocation newLoc else actualRes = res
          @logger?.debug "Player Command action.teleport"
          @logger?.verbose "Player Command action.teleport", {identifier, newLoc}
          actualRes

    custom:
      submit: (identifier, data) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.componentDatabase.submitCustomContent identifier, data else actualRes = res
          @logger?.debug "Player Command custom.submit"
          @logger?.verbose "Player Command custom.submit", {identifier, data}
          actualRes

      redeemGift: (identifier, crierId, giftId) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.componentDatabase.redeemGift identifier, crierId, giftId else actualRes = res
          @logger?.debug "Player Command custom.redeemGift"
          @logger?.verbose "Player Command custom.redeemGift", {identifier, crierId, giftId}
          actualRes

    gender:
      set: (identifier, newGender) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.setGender newGender else actualRes = res
          @logger?.debug "Player Command gender.set"
          @logger?.verbose "Player Command gender.set", {identifier, newGender}
          actualRes

      remove: (identifier) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.setGender '' else actualRes = res
          @logger?.debug "Player Command gender.remove"
          @logger?.verbose "Player Command gender.remove", {identifier}
          actualRes

    auth:
      register: (options) =>
        @logger?.debug "Player Command auth.register"
        @logger?.verbose "Player Command auth.register", {options}
        @gameInstance.playerManager.registerPlayer options

      login: (identifier, suppress) =>
        @logger?.debug "Player Command auth.login"
        @logger?.verbose "Player Command auth.login", {identifier, suppress}
        @gameInstance.playerManager.addPlayer identifier, suppress, no

      loginWithPassword: (identifier, password) =>
        @logger?.debug "Player Command auth.loginWithPassword"
        @logger?.verbose "Player Command auth.loginWithPassword", {identifier, password: "*******"}
        @gameInstance.playerManager.loginWithPassword identifier, password

      setPassword: (identifier, password) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.playerManager.storePasswordFor identifier, password else actualRes = res
          @logger?.debug "Player Command auth.setPassword"
          @logger?.verbose "Player Command auth.setPassword", {identifier, password: "*******"}
          actualRes

      authenticate: (identifier, password) =>
        @logger?.debug "Player Command auth.authenticate"
        @logger?.verbose "Player Command auth.authenticate", {identifier, password: "*******"}
        @gameInstance.playerManager.checkPassword identifier, password, yes

      logout: (identifier) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.playerManager.removePlayer identifier else actualRes = res
          @logger?.debug "Player Command auth.logout"
          @logger?.verbose "Player Command auth.logout", {identifier}
          actualRes

      isTokenValid: (identifier, token) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.playerManager.checkToken identifier, token else actualRes = res
          @logger?.debug "Player Command auth.isTokenValid"
          @logger?.verbose "Player Command auth.isTokenValid", {identifier, token}
          actualRes

    overflow:
      add: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.manageOverflow "add", slot else actualRes = res
          @logger?.debug "Player Command overflow.add"
          @logger?.verbose "Player Command overflow.add", {identifier, slot}
          actualRes

      sell: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.manageOverflow "sell", slot else actualRes = res
          @logger?.debug "Player Command overflow.sell"
          @logger?.verbose "Player Command overflow.sell", {identifier, slot}
          actualRes

      swap: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.manageOverflow "swap", slot else actualRes = res
          @logger?.debug "Player Command overflow.swap"
          @logger?.verbose "Player Command overflow.swap", {identifier, slot}
          actualRes

    personality:
      add: (identifier, personality) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.addPersonality personality else actualRes = res
          @logger?.debug "Player Command personality.add"
          @logger?.verbose "Player Command personality.add", {identifier, personality}
          actualRes

      remove: (identifier, personality) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.removePersonality personality else actualRes = res
          @logger?.debug "Player Command personality.remove"
          @logger?.verbose "Player Command personality.remove", {identifier, personality}
          actualRes

    priority:
      add: (identifier, stat, points) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.addPriority stat, points else actualRes = res
          @logger?.debug "Player Command priority.add"
          @logger?.verbose "Player Command priority.add", {identifier, stat, points}
          actualRes

      set: (identifier, stats) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.setPriorities stats else actualRes = res
          @logger?.debug "Player Command priority.set"
          @logger?.verbose "Player Command priority.set", {identifier, stats}
          actualRes

      remove: (identifier, stat, points) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.addPriority stat, -points else actualRes = res
          @logger?.debug "Player Command priority.remove"
          @logger?.verbose "Player Command priority.remove", {identifier, stat, points}
          actualRes

    pushbullet:
      set: (identifier, apiKey) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.setPushbulletKey apiKey else actualRes = res
          @logger?.debug "Player Command pushbullet.set"
          @logger?.verbose "Player Command pushbullet.set", {identifier, apiKey}
          actualRes

      remove: (identifier) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.setPushbulletKey '' else actualRes = res
          @logger?.debug "Player Command pushbullet.remove"
          @logger?.verbose "Player Command pushbullet.remove", {identifier}
          actualRes

    title:
      set: (identifier, newTitle) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.setTitle newTitle else actualRes = res
          @logger?.debug "Player Command title.set"
          @logger?.verbose "Player Command title.set", {identifier, newTitle}
          actualRes

    string:
      set: (identifier, stringType, string) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.setString stringType, string else actualRes = res
          @logger?.debug "Player Command string.set"
          @logger?.verbose "Player Command string.set", {identifier, stringType, string}
          actualRes

      remove: (identifier, stringType) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.setString stringType else actualRes = res
          @logger?.debug "Player Command string.remove"
          @logger?.verbose "Player Command string.remove", {identifier, stringType}
          actualRes

    pet:
      buy: (identifier, type, name, attr1, attr2) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.buyPet type, name, attr1, attr2 else actualRes = res
          @logger?.debug "Player Command pet.buy"
          @logger?.verbose "Player Command pet.buy", {identifier, type, name, attr1, attr2}
          actualRes

      upgrade: (identifier, stat) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.upgradePet stat else actualRes = res
          @logger?.debug "Player Command pet.upgrade"
          @logger?.verbose "Player Command pet.upgrade", {identifier, stat}
          actualRes

      feed: (identifier) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.feedPet() else actualRes = res
          @logger?.debug "Player Command pet.feed"
          @logger?.verbose "Player Command pet.feed", {identifier}
          actualRes

      takeGold: (identifier) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.takePetGold() else actualRes = res
          @logger?.debug "Player Command pet.takeGold"
          @logger?.verbose "Player Command pet.takeGold", {identifier}
          actualRes

      giveEquipment: (identifier, itemSlot) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.givePetItem itemSlot else actualRes = res
          @logger?.debug "Player Command pet.giveEquipment"
          @logger?.verbose "Player Command pet.giveEquipment", {identifier, itemSlot}
          actualRes

      sellEquipment: (identifier, itemSlot) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.sellPetItem itemSlot else actualRes = res
          @logger?.debug "Player Command pet.sellEquipment"
          @logger?.verbose "Player Command pet.sellEquipment", {identifier, itemSlot}
          actualRes

      takeEquipment: (identifier, itemSlot) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.takePetItem itemSlot else actualRes = res
          @logger?.debug "Player Command pet.takeEquipment"
          @logger?.verbose "Player Command pet.takeEquipment", {identifier, itemSlot}
          actualRes

      equipItem: (identifier, itemSlot) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.equipPetItem itemSlot else actualRes = res
          @logger?.debug "Player Command pet.equipItem"
          @logger?.verbose "Player Command pet.equipItem", {identifier, itemSlot}
          actualRes

      unequipItem: (identifier, itemUid) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.unequipPetItem itemUid else actualRes = res
          @logger?.debug "Player Command pet.unequipItem"
          @logger?.verbose "Player Command pet.unequipItem", {identifier, itemUid}
          actualRes

      setOption: (identifier, option, value) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.setPetOption option, value else actualRes = res
          @logger?.debug "Player Command pet.setOption"
          @logger?.verbose "Player Command pet.setOption", {identifier, option, value}
          actualRes

      swapToPet: (identifier, petId) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.swapToPet petId else actualRes = res
          @logger?.debug "Player Command pet.swapToPet"
          @logger?.verbose "Player Command pet.swapToPet", {identifier, petId}
          actualRes

      changeClass: (identifier, petClass) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.changePetClass petClass else actualRes = res
          @logger?.debug "Player Command pet.changeClass"
          @logger?.verbose "Player Command pet.changeClass", {identifier, petClass}
          actualRes

    guild:
      create: (identifier, guildName) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.guildManager.createGuild identifier, guildName else actualRes = res
          @logger?.debug "Player Command guild.create"
          @logger?.verbose "Player Command guild.create", {identifier, guildName}
          actualRes

      invite: (identifier, invName) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.guildManager.sendInvite identifier, invName else actualRes = res
          @logger?.debug "Player Command guild.invite"
          @logger?.verbose "Player Command guild.invite", {identifier, invName}
          actualRes

      manageInvite: (identifier, accepted, guildName) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.guildManager.manageInvite identifier, accepted, guildName else actualRes = res
          @logger?.debug "Player Command guild.manageInvite"
          @logger?.verbose "Player Command guild.manageInvite", {identifier, accepted, guildName}
          actualRes

      promote: (identifier, memberName) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          guild = res.player.guild
          if res.isSuccess then actualRes = @gameInstance.guildManager.guildHash[guild].promote identifier, memberName else actualRes = res
          @logger?.debug "Player Command guild.promote"
          @logger?.verbose "Player Command guild.promote", {identifier, memberName}
          @logger?.silly "", {actualRes}
          actualRes

      demote: (identifier, memberName) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          guild = res.player.guild
          if res.isSuccess then actualRes = @gameInstance.guildManager.guildHash[guild].demote identifier, memberName else actualRes = res
          @logger?.debug "Player Command guild.demote"
          @logger?.verbose "Player Command guild.demote", {identifier, memberName}
          actualRes

      kick: (identifier, playerName) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.guildManager.kickPlayer identifier, playerName else actualRes = res
          @logger?.debug "Player Command guild.kick"
          @logger?.verbose "Player Command guild.kick", {identifier, playerName}
          actualRes

      disband: (identifier) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.guildManager.disband identifier else actualRes = res
          @logger?.debug "Player Command guild.disband"
          @logger?.verbose "Player Command guild.disband", {identifier}
          actualRes

      leave: (identifier) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.guildManager.leaveGuild identifier else actualRes = res
          @logger?.debug "Player Command guild.leave"
          @logger?.verbose "Player Command guild.leave", {identifier}
          actualRes

      donate: (identifier, gold) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.guildManager.donate identifier, gold else actualRes = res
          @logger?.debug "Player Command guild.donate"
          @logger?.verbose "Player Command guild.donate", {identifier, gold}
          actualRes

      buff: (identifier, type, tier) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          if res.isSuccess then actualRes = @gameInstance.guildManager.addBuff identifier, type, tier else actualRes = res
          @logger?.debug "Player Command guild.buff"
          @logger?.verbose "Player Command guild.buff", {identifier, type, tier}
          actualRes

      changeLeader: (identifier, newLeaderName) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          guild = res.player.guild
          if res.isSuccess then actualRes = @gameInstance.guildManager.guildHash[guild].changeLeader identifier, newLeaderName else actualRes = res
          @logger?.debug "Player Command guild.changeLeader"
          @logger?.verbose "Player Command guild.changeLeader", {identifier, newLeaderName}
          actualRes

      move: (identifier, newLoc) =>
        @validateIdentifier identifier
        .then (res) =>
          guild = res.player.guild
          actualRes = if res.isSuccess then @gameInstance.guildManager.guildHash[guild].moveToBase identifier, newLoc else res
          @logger?.debug "Player Command guild.move"
          @logger?.verbose "Player Command guild.move", {identifier, newLoc}
          actualRes

      construct: (identifier, building, slot) =>
        @validateIdentifier identifier
        .then (res) =>
          guild = res.player.guild
          actualRes = if res.isSuccess then @gameInstance.guildManager.guildHash[guild].construct identifier, building, slot else res
          @logger?.debug "Player Command guild.construct"
          @logger?.verbose "Player Command guild.construct", {identifier, building, slot}
          actualRes

      upgrade: (identifier, building) =>
        @validateIdentifier identifier
        .then (res) =>
          guild = res.player.guild
          actualRes = if res.isSuccess then @gameInstance.guildManager.guildHash[guild].upgrade identifier, building else res
          @logger?.debug "Player Command guild.upgrade"
          @logger?.verbose "Player Command guild.upgrade", {identifier, building}
          actualRes

      setProperty: (identifier, building, property, value) =>
        @validateIdentifier identifier
        .then (res) =>
          actualRes = null
          guild = res.player.guild
          actualRes = if res.isSuccess then @gameInstance.guildManager.guildHash[guild].setProperty identifier, building, property, value else res
          @logger?.debug "Player Command guild.setProperty"
          @logger?.verbose "Player Command guild.setProperty", {identifier, building, property, value}
          actualRes

      tax:
        whole: (identifier, taxPercent) =>
          @validateIdentifier identifier
          .then (res) =>
            actualRes = null
            guild = res.player.guild
            if res.isSuccess then actualRes = @gameInstance.guildManager.guildHash[guild].setTax identifier, taxPercent else actualRes = res
            @logger?.debug "Player Command guild.tax.whole"
            @logger?.verbose "Player Command guild.tax.whole", {identifier, taxPercent}
            actualRes

        self: (identifier, taxPercent) =>
          @validateIdentifier identifier
          .then (res) ->
            actualRes = null
            if res.isSuccess then actualRes = res.player.setSelfGuildTax taxPercent else actualRes = res
            @logger?.debug "Player Command guild.tax.self"
            @logger?.verbose "Player Command guild.tax.self", {identifier, taxPercent}
            actualRes

    shop:
      buy: (identifier, slot) =>
        @validateIdentifier identifier
        .then (res) ->
          actualRes = null
          if res.isSuccess then actualRes = res.player.buyShop slot else actualRes = res
          @logger?.debug "Player Command shop.buy"
          @logger?.verbose "Player Command shop.buy", {identifier, slot}
          actualRes
      
module.exports = exports = API