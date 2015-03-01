
Datastore = require "./../database/DatabaseWrapper"
_ = require "lodash"
Guild = require "../../character/player/Guild"
RestrictedNumber = require "restricted-number"
Q = require "q"
MessageCreator = require "./../handlers/MessageCreator"
Constants = require "./../utilities/Constants"
requireDir = require "require-dir"
guildBuffs = requireDir "../../character/guildBuffs", recurse: yes
convenienceFunctions = require "../../system/utilities/ConvenienceFunctions"

class GuildManager

  guilds: []
  guildHash: {}
  invites: []

  defer: Q.defer()

  constructor: (@game) ->
    @db = new Datastore "guilds", (db) ->
      db.ensureIndex { name: 1 }, { unique: true }, ->

    if @game and @game.logManager
      @logManager = @game.logManager
    else
      @logManager = new LogManager()
      @logManager.getLogger("GuildManager").warn "@game.logManager not set, using isolated LogManager instance, not able to set logger level via !idle-setloggerlevel"

    @loadAllGuilds()

    # Check guild buffs every minute, which is 60000 ms
    @checkBuffInterval = setInterval =>
      @checkBuffs()
    , 60000

  waitForGuild: ->
    @defer.promise

  createGuild: (identifier, name) ->
    defer = Q.defer()
    player = @game.playerManager.getPlayerById identifier

    cleanedName = convenienceFunctions.sanitizeStringNoPunctuation name.trim()

    return Q {isSuccess: no, code: 51, message: "That player does not exist!"} if not player
    return Q {isSuccess: no, code: 53, message: "You're already in a guild (#{player.guild})!"} if player.guild
    return Q {isSuccess: no, code: 54, message: "Your guild name has to be at least 3 characters!"} if cleanedName.length < 3
    return Q {isSuccess: no, code: 55, message: "You can't have a guild name larger than 50 characters!"} if cleanedName.length > 50
    return Q {isSuccess: no, code: 4, message: "You can't have dots in your guild name. Sorry!"} if -1 isnt cleanedName.indexOf "."

    goldCost = Constants.defaults.game.guildCreateCost

    return Q {isSuccess: no, code: 56, message: "You need #{goldCost} gold to make a guild!"} if player.gold.getValue() < goldCost

    guildObject = new Guild {name: name, leader: player.identifier}
    guildObject.guildManager = @
    guildObject.leaderName = player.name
    guildObject.members.push {identifier: player.identifier, name: player.name, isAdmin: yes}
    saveObj = @buildGuildSaveObject guildObject

    @db.insert saveObj, (iErr) =>

      return defer.resolve {isSuccess: no, code: 57, message: "Guild creation error: #{iErr} (that name is probably already taken)"} if iErr

      @guildHash[name] = guildObject
      @guilds.push guildObject
      player.guild = name
      player.guildStatus = 2
      player.gold.sub goldCost
      player.save()

      guildObject.avgLevel()

      message = "%player has founded the guild %guildName!"
      @game.eventHandler.broadcastEvent {message: message, player: player, extra: {guildName: name}, type: 'guild'}

      defer.resolve player.getExtraDataForREST {player: yes, guild: yes}, {isSuccess: yes, code: 69, message: "You've successfully founded the guild \"#{name}!\""}

    defer.promise

  saveGuild: (guild) ->
    saveGuild = @buildGuildSaveObject guild
    @db.update { name: guild.name }, saveGuild, {upsert: true}, (e) =>
      @game.errorHandler.captureException e if e

  loadAllGuilds: ->
    @retrieveAllGuilds (guilds) =>
      _.each guilds, (guild) =>
        return if _.findWhere @guilds, {name: guild.name}
        guild.__proto__ = Guild.prototype
        guild.guildManager = @
        guild.invitesLeft()

        guild.buffs = _.compact guild.buffs
        guild.invites = [] if not guild.invites

        for key, val of guild.invites
          @invites[val] = [] if not @invites[val]
          @invites[val].push guild.name

        _.each guild.buffs, (buff) ->
          if guildBuffs["Guild#{buff.type}"]
            buff.__proto__ = guildBuffs["Guild#{buff.type}"].prototype
          else guild.buffs = _.without guild.buffs, buff

        guild.avgLevel()

        if not guild.base
          guild.base = "Norkos"
          guild.buildingLevels = {}
          guild.buildingLevelCosts = {}
          guild.buildingProps = {}
          guild.resetBuildings()
          guild.save()

        guild.buildBase()

        guild.initGold() unless guild.gold
        guild.gold.__current = 0 if _.isNaN guild.gold.__current
        guild.gold.__proto__ = RestrictedNumber.prototype

        @guilds.push guild
        @guildHash[guild.name] = guild

      @checkBuffs()
      @defer.resolve()

  retrieveAllGuilds: (callback) ->
    @db.find {}, {}, (e, guilds) =>
      @game.errorHandler.captureException e if e
      callback guilds

  sendInvite: (sendId, invName) ->
    sender = @game.playerManager.getPlayerById sendId
    invitee = @game.playerManager.getPlayerByName invName

    @guildHash[sender.guild].invitesLeft()

    return Q {isSuccess: no, code: 58, message: "You didn't specify a valid invitation target!"} if not invitee
    return Q {isSuccess: no, code: 59, message: "You aren't part of a guild!"} if not sender?.guild
    return Q {isSuccess: no, code: 60, message: "That person already has a guild!"} if invitee?.guild
    return Q {isSuccess: no, code: 61, message: "You're not an admin in that guild!"} if not @checkAdmin sender.name
    return Q {isSuccess: no, code: 62, message: "You've already invited that person!"} if _.contains @guildHash[sender.guild]?.invites, invitee?.identifier
    return Q {isSuccess: no, code: 63, message: "You don't have any available invites!"} if not @guildHash[sender.guild]?.invitesLeft()

    @invites[invitee.identifier] = [] if not @invites[invitee.identifier]
    @invites[invitee.identifier].push sender.guild

    guild = @guildHash[sender.guild]
    guild.invites.push invitee.identifier
    guild.save()

    Q sender.getExtraDataForREST {player: yes, guild: yes}, {isSuccess: yes, code: 70, message: "Successfully sent an invite to #{invName}! You have #{@guildHash[sender.guild].invitesLeft()} invites remaining."}

  rescindInvite: (adminId, invName) ->
    admin = @game.playerManager.getPlayerById adminId
    invitee = @game.playerManager.getPlayerByName invName

    return Q {isSuccess: no, code: 59, message: "You aren't part of a guild!"} unless admin?.guild
    return Q {isSuccess: no, code: 61, message: "You're not an admin in that guild!"} unless @checkAdmin admin.name
    return Q {isSuccess: no, code: 58, message: "You didn't specify a valid invitation target!"} unless invitee
    return Q {isSuccess: no, code: 987, message: "That person does not have an invite to your guild!"} unless _.contains @invites[invitee.identifier], admin.guild

    @manageInvite invitee.identifier, no, admin.guild

    guild = @guildHash[admin.guild]
    guild.save()

    Q admin.getExtraDataForREST {guild: yes}, {isSuccess: yes, code: 869, message: "Successfully took the invite from #{invName}! You have #{guild.invitesLeft()} invites remaining."}


  manageInvite: (invId, accepted, guildName) ->
    invitee = @game.playerManager.getPlayerById invId

    return Q {isSuccess: no, code: 64, message: "That invite doesn't appear to exist!"} unless _.contains @invites[invitee.identifier], guildName
    return Q {isSuccess: no, code: 65, message: "That guild does not exist!"} unless @guildHash[guildName]
    return Q {isSuccess: no, code: 53, message: "You're already in a guild!"} if invitee.guild

    @invites[invitee.identifier] = _.without @invites[invitee.identifier], guildName
    @guildHash[guildName].invites = _.without @guildHash[guildName].invites, invitee.identifier
    if accepted
      @guildHash[guildName].add invitee
      @clearInvites invitee

    @guildHash[guildName].save()

    Q invitee.getExtraDataForREST {player: yes, guild: yes}, {isSuccess: yes, code: 71, message: "Guild invite was resolved successfully."}

  clearInvites: (player) ->
    _.each @invites[player.identifier], ((guild) => @manageInvite player, no, guild), @
    @invites[player.identifier] = []

  buildGuildSaveObject: (guild) ->
    ret = _.omit guild, 'guildManager', '_id'
    ret

  checkAdmin: (playerName, guildName = @game.playerManager.getPlayerByName(playerName).guild) ->
    return false unless guildName
    (@findMember playerName, guildName)?.isAdmin

  findMember: (playerName, guildName) ->
    return false unless @guildHash[guildName]
    _.findWhere @guildHash[guildName].members, {name: playerName}

  getGuildByName: (guildName) ->
    @guildHash[guildName]

  getPlayerInvites: (player) ->
    @invites[player.identifier]

  leaveGuild: (identifier) ->
    player = @game.playerManager.getPlayerById identifier

    return Q {isSuccess: no, code: 59, message: "You aren't in a guild!"} unless player.guild

    if player.identifier is @guildHash[player.guild].leader
      return @disband player.identifier
    else
      @guildHash[player.guild].remove player.name
      return Q player.getExtraDataForREST {player: yes}, {isSuccess: yes, code: 72, message: "You've successfully left the guild.", guild: null}

  kickPlayer: (adminId, playerName) ->
    admin = @game.playerManager.getPlayerById adminId
    return Q {isSuccess: no, code: 59, message: "You aren't in a guild!"} unless admin.guild
    return Q {isSuccess: no, code: 61, message: "You aren't a guild administrator!"} unless @checkAdmin admin.name
    return Q {isSuccess: no, code: 61, message: "That player isn't in your guild!"} unless @findMember playerName, admin.guild
    return Q {isSuccess: no, code: 66, message: "You can't kick another administrator!"} if @checkAdmin playerName, admin.guild

    guild = @guildHash[admin.guild]
    guild.remove playerName

    Q admin.getExtraDataForREST {guild: yes}, {isSuccess: yes, code: 73, message: "You've kicked #{playerName} successfully."}

  disband: (identifier) ->
    player = @game.playerManager.getPlayerById identifier

    if @guildHash[player.guild].leader isnt player.identifier
      return Q {isSuccess: no, code: 50, message: "You aren't the leader of that guild!"}

    guild = @guildHash[player.guild]
    _.each guild.invites, (identifier) => @invites[identifier] = _.without @invites[identifier], player.guild

    guild.notifyAllPossibleMembers "Your guild, \"#{guild.name}\" has disbanded."

    # online players
    _.each guild.members, (member) =>
      player = @game.playerManager.getPlayerById member.identifier

      return if not player
      player.guild = null
      player.guildStatus = -1
      player.save()

    # offline players
    @game.playerManager.db.update {guild: @name}, {$set: {guild: null}}, {}, (e) => @game.errorHandler.captureException e if e

    @guilds = _.reject @guilds, (guildTest) -> guild.name is guildTest.name
    delete @guildHash[guild.name]
    @db.remove {name: guild.name}

    Q player.getExtraDataForREST {player: yes}, {isSuccess: yes, code: 74, message: "You've successfully disbanded your guild.", guild: null}

  checkBuffs: ->
    for guild in @guilds
      guild.buffs = [] unless guild.buffs
      rejectedBuffs = _.filter guild.buffs, ((buff) -> buff.expire < Date.now())
      if guild.hasBuilt("Academy") and (guild.buildingProps?.Academy?.AutoRenew is "Yes")
        for buff in rejectedBuffs
          renewCost = buff.getTier(buff.tier).cost * Constants.defaults.game.guildRenewMultiplier

          if renewCost > guild.gold.getValue()
            guild.buffs = _.without guild.buffs, buff
            continue

          guild.subGold renewCost
          buff.refresh buff.tier

        guild.save()
      else
        guild.buffs = _.reject guild.buffs, ((buff) -> buff.expire < Date.now())

  addBuff: (identifier, type, tier) ->
    player = @game.playerManager.getPlayerById identifier

    return Q {isSuccess: no, code: 59, message: "You aren't in a guild!"} unless player.guild
    return Q {isSuccess: no, code: 61, message: "You aren't a guild administrator!"} unless @checkAdmin player.name, player.guild

    typeString = "Guild#{type}"

    return Q {isSuccess: no, code: 150, message: "That is not a valid guild buff type!"} unless guildBuffs[typeString]
    return Q {isSuccess: no, code: 151, message: "That is not a valid tier!"} unless tier > 0
    guild = @guildHash[player.guild]

    return Q {isSuccess: no, code: 78, message: "You need to build a guild academy first!"} unless guild.hasBuilt("Academy")

    requiredLevel = tier * 10 + 1
    return Q {isSuccess: no, code: 78, message: "You need to build a upgrade the academy to level #{requiredLevel} first!"} unless tier <= guild.buildingGlobals["Academy"]?.maxBuffLevel

    tempBuff = new guildBuffs[typeString] tier
    tierLevel = tempBuff.getTier(tier).level
    tierMembers = tempBuff.getTier(tier).members
    tierGold = tempBuff.getTier(tier).cost
    return Q {isSuccess: no, code: 152, message: "Your guild is not a high enough level! It needs to be level #{tierLevel} first!"} if tierLevel > guild.level
    return Q {isSuccess: no, code: 153, message: "Your guild does not have enough members! You need #{tierMembers} members!"} if tierMembers > guild.members.length
    return Q {isSuccess: no, code: 56, message: "Your guild does not have enough gold! You need #{tierGold} gold!"} if tierGold > guild.gold.getValue()

    guild.subGold tempBuff.getTier(tier).cost

    guild.buffs = [] if not guild.buffs
    current = _.findWhere guild.buffs, {type: type}

    if current?
      return Q {isSuccess: no, code: 154, message: "Your guild already has a higher tier of this buff (currently: #{current.tier})!"} if current.tier > tier
      if current.tier is tier
        current.refresh tier
        guild.save()
        return Q player.getExtraDataForREST {player: yes, guild: yes}, {isSuccess: yes, code: 155, message: "You have refreshed the #{current.name} guild buff."}
      else
        guild.buffs = _.without guild.buffs, current

    guild.buffs.push (tempBuff)
    guild.save()

    Q player.getExtraDataForREST {player: yes, guild: yes}, {isSuccess: yes, code: 156, message: "You have purchased the #{tempBuff.name} guild buff."}


  donate: (identifier, gold) ->
    player = @game.playerManager.getPlayerById identifier

    return Q {isSuccess: no, code: 59, message: "You aren't in a guild!"} unless player.guild
    return Q {isSuccess: no, code: 56, message: "You don't have enough gold!"} if player.gold.getValue() < gold
    return Q {isSuccess: no, code: 63, message: "Stop trying to steal gold!"} if gold <= 0
    return Q {isSuccess: no, code: 64, message: "That's an invalid amount of gold! You might mess something up if you do that!"} if _.isNaN parseInt gold

    guild = @guildHash[player.guild]
    gold = Math.round Math.min gold, guild.gold.maximum-guild.gold.getValue() #Prevent overdonation

    guild.addGold gold
    player.gold.sub gold
    guild.save()

    ##TAG:EVENT_PLAYER: gold.guildDonation | guild.name, gold | Emitted when a player willingly donates gold to their guild
    player.emit "player.gold.guildDonation", guild.name, gold

    Q player.getExtraDataForREST {player: yes, guild: yes}, {isSuccess: yes, code: 157, message: "You have donated #{gold} gold to \"#{guild.name}.\""}

module.exports = exports = GuildManager
