
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

  constructor: (@game) ->
    @db = new Datastore "guilds", (db) ->
      db.ensureIndex { name: 1 }, { unique: true }, ->

    @loadAllGuilds()

  createGuild: (identifier, name) ->
    defer = Q.defer()
    player = @game.playerManager.getPlayerById identifier

    cleanedName = name.trim()

    return Q {isSuccess: no, message: "That player does not exist!"} if not player
    return Q {isSuccess: no, message: "You're already in a guild (#{player.guild})!"} if player.guild
    return Q {isSuccess: no, message: "Your guild name has to be at least 3 characters!"} if cleanedName.length < 3
    return Q {isSuccess: no, message: "You can't have a guild name larger than 50 characters!"} if cleanedName.length > 50

    goldCost = Constants.defaults.game.guildCreateCost

    return Q {isSuccess: no, message: "You need #{goldCost} gold to make a guild!"} if player.gold.getValue() < goldCost

    guildObject = new Guild {name: name, leader: player.identifier}
    guildObject.guildManager = @
    guildObject.__proto__ = Guild.prototype
    guildObject.members.push {identifier: player.identifier, name: player.name, isAdmin: yes}
    saveObj = @buildGuildSaveObject guildObject

    @db.insert saveObj, (iErr) =>
      if iErr
        message = "Guild creation error: #{iErr} (that name is probably already taken)"
        defer.resolve {isSuccess: no, message: message}
        return

      @guildHash[name] = guildObject
      @guilds.push guildObject
      player.guild = name
      player.gold.sub goldCost
      player.save()

      message = "%player has founded the guild %guildName!"
      @game.eventHandler.broadcastEvent message, player, guildName: name
      defer.resolve {isSuccess: yes, message: "You've successfully founded the guild \"#{name}!\""}

    defer.promise

  saveGuild: (guild) ->
    saveGuild = @buildGuildSaveObject guild
    @db.update { name: guild.name }, saveGuild, {upsert: true}, (e) ->
      console.error "Save error: #{e}" if e

  loadAllGuilds: ->
    @retrieveAllGuilds (guilds) =>
      _.each guilds, ((guild) ->
        return if _.findWhere @guilds, {name: guild.name}
        guild.__proto__ = Guild.prototype
        guild.guildManager = @
        @guilds.push guild
        @guildHash[guild.name] = guild), @

  retrieveAllGuilds: (callback) ->
    @db.find {}, (e, guilds) ->
      console.error e if e
      callback guilds

  sendInvite: (sendId, invName) ->
    sender = @game.playerManager.getPlayerById sendId
    invitee = @game.playerManager.getPlayerByName invName

    return Q {isSuccess: no, message: "You didn't specify a valid invitation target!"} if not invitee
    return Q {isSuccess: no, message: "You aren't part of a guild!"} if not sender?.guild
    return Q {isSuccess: no, message: "That person already has a guild!"} if invitee?.guild
    return Q {isSuccess: no, message: "You're not an admin in that guild!"} if not @checkAdmin sender
    return Q {isSuccess: no, message: "You've already invited that person!"} if _.contains @guildHash[sender.guild]?.invites, invitee?.identifier
    return Q {isSuccess: no, message: "You don't have any available invites!"} if not @guildHash[sender.guild]?.invitesLeft()

    @invites[invitee.identifier] = [] if not @invites[invitee.identifier]
    @invites[invitee.identifier].push sender.guild
    @guildHash[sender.guild].invites.push invitee.identifier
    @guildHash[sender.guild].save()
    Q {isSuccess: yes, message: "Successfully sent an invite to #{invName}! You have #{@guildHash[sender.guild].invitesLeft()} invites remaining."}

  manageInvite: (invId, accepted, guildName) ->
    invitee = @game.playerManager.getPlayerById invId

    return Q {isSuccess: no, message: "That invite doesn't appear to exist!"} if not _.contains @invites[invitee.identifier], guildName
    return Q {isSuccess: no, message: "That guild does not exist!"} if not @guildHash[guildName]
    return Q {isSuccess: no, message: "You're already in a guild!"} if invitee.guild

    @invites[invitee.identifier] = _.without @invites[invitee.identifier], guildName
    @guildHash[guildName].invites = _.without @guildHash[guildName].invites, invitee.identifier
    if accepted
      @guildHash[guildName].add invitee
      @clearInvites invitee

    @guildHash[guildName].save()

    Q {isSuccess: no, message: "Guild invite was resolved successfully."}

  clearInvites: (player) ->
    _.each @invites[player.identifier], ((guild) -> @manageInvite player, no, guild), @
    @invites[player.identifier] = []

  buildGuildSaveObject: (guild) ->
    ret = _.omit guild, 'guildManager'
    ret.invites = []
    ret

  checkAdmin: (player) ->
    return false if not player.guild
    (_.findWhere @guildHash[player.guild].members, {identifier: player.identifier}).isAdmin

  leaveGuild: (identifier) ->
    player = @game.playerManager.getPlayerById identifier


    return Q {isSuccess: no, message: "You aren't in a guild!"} if not player.guild

    if player.identifier is @guildHash[player.guild].leader
      return @disband player.identifier
    else
      @guildHash[player.guild].remove player
      return Q {isSuccess: no, message: "You've successfully left the guild."}

  kickPlayer: (adminId, playerName) ->
    admin = @game.playerManager.getPlayerById adminId
    player = @game.playerManager.getPlayerByName playerName

    return Q {isSuccess: no, message: "You aren't in a guild!"} if not admin.guild
    return Q {isSuccess: no, message: "You aren't a guild administrator!"} if not @checkAdmin admin
    return Q {isSuccess: no, message: "You can't kick another administrator!"} if @checkAdmin player

    @guildHash[player.guild].remove player if not resolved

    Q {isSuccess: no, message: "You've kicked #{player.name} successfully."}

  disband: (identifier) ->
    player = @game.playerManager.getPlayerById identifier

    if @guildHash[player.guild].leader isnt player.identifier
      return Q {isSuccess: no, message: "You aren't the leader of that guild!"}

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

    Q {isSuccess: yes, message: "You've successfully disbanded your guild."}

module.exports = exports = GuildManager
