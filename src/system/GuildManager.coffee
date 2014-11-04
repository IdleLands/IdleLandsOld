
Datastore = require "./DatabaseWrapper"
_ = require "underscore"
Guild = require "../character/player/Guild"
RestrictedNumber = require "restricted-number"
Q = require "q"
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"

class GuildManager

  guilds: []
  guildHash: {}
  invites: []

  defer: Q.defer()

  constructor: (@game) ->
    @db = new Datastore "guilds", (db) ->
      db.ensureIndex { name: 1 }, { unique: true }, ->

    @loadAllGuilds()

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
    @db.update { name: guild.name }, saveGuild, {upsert: true}, (e) ->
      console.error "Save error: #{e}" if e

  loadAllGuilds: ->
    @retrieveAllGuilds (guilds) =>
      _.each guilds, (guild) =>
        return if _.findWhere @guilds, {name: guild.name}
        guild.__proto__ = Guild.prototype
        guild.guildManager = @
        guild.invitesLeft()
        guild.avgLevel()
        @guilds.push guild
        @guildHash[guild.name] = guild

      @defer.resolve()

  retrieveAllGuilds: (callback) ->
    @db.find {}, (e, guilds) ->
      console.error e if e
      callback guilds

  sendInvite: (sendId, invName) ->
    sender = @game.playerManager.getPlayerById sendId
    invitee = @game.playerManager.getPlayerByName invName

    @guildHash[sender.guild].invitesLeft()

    return Q {isSuccess: no, code: 58, message: "You didn't specify a valid invitation target!"} if not invitee
    return Q {isSuccess: no, code: 59, message: "You aren't part of a guild!"} if not sender?.guild
    return Q {isSuccess: no, code: 60, message: "That person already has a guild!"} if invitee?.guild
    return Q {isSuccess: no, code: 61, message: "You're not an admin in that guild!"} if not @checkAdmin sender
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
    _.each @invites[player.identifier], ((guild) -> @manageInvite player, no, guild), @
    @invites[player.identifier] = []

  buildGuildSaveObject: (guild) ->
    ret = _.omit guild, 'guildManager', '_id'
    ret.invites = []
    ret

  checkAdmin: (player) ->
    return false if not player.guild
    (_.findWhere @guildHash[player.guild].members, {identifier: player.identifier}).isAdmin

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
    player = @game.playerManager.getPlayerByName playerName

    return Q {isSuccess: no, code: 59, message: "You aren't in a guild!"} if not admin.guild
    return Q {isSuccess: no, code: 61, message: "You aren't a guild administrator!"} if not @checkAdmin admin
    return Q {isSuccess: no, code: 66, message: "You can't kick another administrator!"} if @checkAdmin player

    @guildHash[player.guild].remove player if not resolved

    Q {isSuccess: yes, code: 73, message: "You've kicked #{player.name} successfully."}

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
      player.save()

    # offline players
    @game.playerManager.db.update {guild: @name}, {$set: {guild: null}}

    @guilds = _.reject @guilds, (guildTest) -> guild.name is guildTest.name
    delete @guildHash[guild.name]
    @db.remove {name: guild.name}

    Q {isSuccess: yes, code: 74, message: "You've successfully disbanded your guild."}

module.exports = exports = GuildManager
