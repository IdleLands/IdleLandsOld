
Datastore = require "./DatabaseWrapper"
_ = require "lodash"
Guild = require "../character/player/Guild"
RestrictedNumber = require "restricted-number"
Q = require "q"
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"
requireDir = require "require-dir"
guildBuffs = requireDir "../character/guildBuffs", recurse: yes

class GuildManager

  guilds: []
  guildHash: {}
  invites: []

  defer: Q.defer()

  constructor: (@game) ->
    @db = new Datastore "guilds", (db) ->
      db.ensureIndex { name: 1 }, { unique: true }, ->

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

    cleanedName = name.trim()

    return Q {isSuccess: no, code: 51, message: "That player does not exist!"} if not player
    return Q {isSuccess: no, code: 53, message: "You're already in a guild (#{player.guild})!"} if player.guild
    return Q {isSuccess: no, code: 54, message: "Your guild name has to be at least 3 characters!"} if cleanedName.length < 3
    return Q {isSuccess: no, code: 55, message: "You can't have a guild name larger than 50 characters!"} if cleanedName.length > 50

    goldCost = Constants.defaults.game.guildCreateCost

    return Q {isSuccess: no, code: 56, message: "You need #{goldCost} gold to make a guild!"} if player.gold.getValue() < goldCost

    guildObject = new Guild {name: name, leader: player.identifier}
    guildObject.guildManager = @
    guildObject.__proto__ = Guild.prototype
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
      defer.resolve {isSuccess: yes, code: 69, message: "You've successfully founded the guild \"#{name}!\""}

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
        guild.avgLevel()
        guild.gold = new RestrictedNumber 0, 9999999999, 0 if not guild.gold
        guild.gold.__current = 0 if _.isNaN guild.gold.__current
        guild.gold.__proto__ = RestrictedNumber.prototype
        guild.buffs = _.compact guild.buffs
        _.each guild.buffs, (buff) ->
          if guildBuffs["Guild#{buff.type}"]
            buff.__proto__ = guildBuffs["Guild#{buff.type}"].prototype
          else guild.buffs = _.without buff
        @guilds.push guild
        @guildHash[guild.name] = guild
      @checkBuffs()
      @defer.resolve()

  retrieveAllGuilds: (callback) ->
    @db.find {}, (e, guilds) =>
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
    @guildHash[sender.guild].invites.push invitee.identifier
    @guildHash[sender.guild].save()
    Q {isSuccess: yes, code: 70, message: "Successfully sent an invite to #{invName}! You have #{@guildHash[sender.guild].invitesLeft()} invites remaining."}

  manageInvite: (invId, accepted, guildName) ->
    invitee = @game.playerManager.getPlayerById invId

    return Q {isSuccess: no, code: 64, message: "That invite doesn't appear to exist!"} if not _.contains @invites[invitee.identifier], guildName
    return Q {isSuccess: no, code: 65, message: "That guild does not exist!"} if not @guildHash[guildName]
    return Q {isSuccess: no, code: 53, message: "You're already in a guild!"} if invitee.guild

    @invites[invitee.identifier] = _.without @invites[invitee.identifier], guildName
    @guildHash[guildName].invites = _.without @guildHash[guildName].invites, invitee.identifier
    if accepted
      @guildHash[guildName].add invitee
      @clearInvites invitee

    @guildHash[guildName].save()

    Q {isSuccess: yes, code: 71, message: "Guild invite was resolved successfully."}

  clearInvites: (player) ->
    _.each @invites[player.identifier], ((guild) => @manageInvite player, no, guild), @
    @invites[player.identifier] = []

  buildGuildSaveObject: (guild) ->
    ret = _.omit guild, 'guildManager', '_id'
    ret.invites = []
    ret

  checkAdmin: (playerName, guildName = @game.playerManager.getPlayerByName(playerName).guild) ->
    return false if not guildName
    (@findMember playerName, guildName)?.isAdmin

  findMember: (playerName, guildName) ->
    return false if not @guildHash[guildName]
    _.findWhere @guildHash[guildName].members, {name: playerName}

  leaveGuild: (identifier) ->
    player = @game.playerManager.getPlayerById identifier

    return Q {isSuccess: no, code: 59, message: "You aren't in a guild!"} if not player.guild

    if player.identifier is @guildHash[player.guild].leader
      return @disband player.identifier
    else
      @guildHash[player.guild].remove player
      return Q {isSuccess: yes, code: 72, message: "You've successfully left the guild."}

  kickPlayer: (adminId, playerName) ->
    admin = @game.playerManager.getPlayerById adminId
    return Q {isSuccess: no, code: 59, message: "You aren't in a guild!"} if not admin.guild
    return Q {isSuccess: no, code: 61, message: "You aren't a guild administrator!"} if not @checkAdmin admin.name
    return Q {isSuccess: no, code: 61, message: "That player isn't in your guild!"} if not @findMember playerName, admin.guild
    return Q {isSuccess: no, code: 66, message: "You can't kick another administrator!"} if @checkAdmin playerName, admin.guild

    @guildHash[admin.guild].remove playerName

    Q {isSuccess: yes, code: 73, message: "You've kicked #{playerName} successfully."}

  disband: (identifier) ->
    player = @game.playerManager.getPlayerById identifier

    if @guildHash[player.guild].leader isnt player.identifier
      return Q {isSuccess: no, code: 50, message: "You aren't the leader of that guild!"}

    guild = @guildHash[player.guild]
    _.each guild.invites, (identifier) => @invites[identifier] = _.without @invites[identifier], player.guild

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

    Q {isSuccess: yes, code: 74, message: "You've successfully disbanded your guild."}

  checkBuffs: ->
    for guild in @guilds
      guild.buffs = [] if not guild.buffs
      guild.buffs = _.reject guild.buffs, ((buff) -> buff.expire < Date.now())

  addBuff: (identifier, type, tier) ->
    player = @game.playerManager.getPlayerById identifier
    return Q {isSuccess: no, code: 59, message: "You aren't in a guild!"} if not player.guild
    return Q {isSuccess: no, code: 61, message: "You aren't a guild admin!"} if not @checkAdmin player.name
    typeString = "Guild#{type}"
    return Q {isSuccess: no, code: 150, message: "That is not a valid guild buff type!"} if not guildBuffs[typeString]
    return Q {isSuccess: no, code: 151, message: "That is not a valid tier!"} if not guildBuffs[typeString].tiers[tier]
    guild = @guildHash[player.guild]
    return Q {isSuccess: no, code: 152, message: "Your guild is not a high enough level!"} if guildBuffs[typeString].tiers[tier].level > guild.level
    return Q {isSuccess: no, code: 153, message: "Your guild does not have enough members!"} if guildBuffs[typeString].tiers[tier].members > guild.members.length

    guild.gold = new RestrictedNumber 0, 9999999999, 0 if not guild.gold
    return Q {isSuccess: no, code: 56, message: "Your guild does not have enough gold!"} if guildBuffs[typeString].tiers[tier].cost > guild.gold.getValue()
    guild.gold.sub guildBuffs[typeString].tiers[tier].cost

    guild.buffs = [] if not guild.buffs
    current = _.findWhere guild.buffs, {type: type}
    if current?
      return Q {isSuccess: no, code: 154, message: "Your guild already has a higher tier of this buff!"} if current.tier > tier
      if current.tier is tier
        current.refresh tier
        guild.save()
        return Q {isSuccess: yes, code: 155, message: "You have refreshed the #{current.name} guild buff."}
      else
        guild.buffs = _.without guild.buffs, current
    buff = new guildBuffs[typeString] tier
    guild.buffs.push (new guildBuffs[typeString] tier)
    guild.save()
    return Q {isSuccess: yes, code: 156, message: "You have purchased the #{buff.name} guild buff."}

  donate: (identifier, gold) ->
    player = @game.playerManager.getPlayerById identifier
    console.log player.guild
    return Q {isSuccess: no, code: 59, message: "You aren't in a guild!"} if not player.guild
    return Q {isSuccess: no, code: 56, message: "You don't have enough gold!"} if player.gold.getValue() < gold
    guild = @guildHash[player.guild]
    guild.gold = new RestrictedNumber 0, 9999999999, 0 if not @guildHash[player.guild].gold
    gold = Math.min gold, guild.gold.maximum-guild.gold.getValue() #Prevent overdonation
    guild.gold.add gold
    player.gold.sub gold
    guild.save()
    player.save()
    return Q {isSuccess: yes, code: 157, message: "You have donated #{gold} gold to #{guild.name}."}

module.exports = exports = GuildManager
