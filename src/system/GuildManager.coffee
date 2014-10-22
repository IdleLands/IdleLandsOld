
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

  createGuild: (player, name, callback) ->
    return -1 if (player.guild?) or player.gold.getValue() < 100000
    guildObject = new Guild {name: name, leader: player.identifier}
    guildObject.guildManager = @
    guildObject.__proto__ = Guild.prototype
    guildObject.members.push {identifier: player.identifier, isAdmin: yes}
    saveObj = @buildGuildSaveObject guildObject

    @db.insert saveObj, (iErr) =>
      if iErr
        console.error "Player creation error: #{iErr}", playerObject if callback?
        callback?(iErr)
        return
      @guildHash[name] = guildObject
      @guilds.push guildObject
      player.guild = name
      player.gold.sub 100000
      player.save()
      callback?({ success: true, name: options.name })
    return guildObject.name

  saveGuild: (guild) ->
    saveGuild = @buildGuildSaveObject guild
    @db.update { name: guild.name }, saveGuild, {upsert: true}, (e) ->
      console.error "Save error: #{e}" if e

  loadAllGuilds: ->
    console.log MessageCreator.genericMessage "Loading guilds!"
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

  sendInvite: (sender, invitee) ->
    return -1 if (not invitee) or (not sender.guild) or invitee.guild? or
      (not @checkAdmin sender) or (_.contains @guildHash[sender.guild].invites, invitee.identifier) or
      (not @guildHash[sender.guild].invitesLeft())
    @invites[invitee.identifier] = [] if not @invites[invitee.identifier]
    @invites[invitee.identifier].push sender.guild
    @guildHash[sender.guild].invites.push invitee.identifier
    @guildHash[sender.guild].save()
    return @guildHash[sender.guild].invitesLeft()

  manageInvite: (invitee, accepted, guildName) ->
    return -1 if (not _.contains @invites[invitee.identifier], guildName) or
      (not @guildHash[guildName]?) or invitee.guild?
    @invites[invitee.identifier] = _.without @invites[invitee.identifier], guildName
    @guildHash[guildName].invites = _.without @guildHash[guildName].invites, invitee.identifier
    if accepted
      @guildHash[guildName].add invitee
      @clearInvites invitee
    @guildHash[guildName].save()

  clearInvites: (player) ->
    _.each @invites[player.identifier], ((guild) -> @manageInvite player, no, guild), @
    @invites[player.identifier] = []

  buildGuildSaveObject: (guild) ->
    ret = _.omit guild, 'guildManager'
    ret.invites = []
    ret

  checkAdmin: (player) ->
    return -1 if not player.guild?
    (_.findWhere @guildHash[player.guild].members, {identifier: player.identifier}).isAdmin

  leaveGuild: (player) ->
    return -1 if not player.guild
    (@disband player) if player.identifier is @guildHash[player.guild].leader
    else @guildHash[player.guild].remove player

  kickPlayer: (admin, player) ->
    return -1 if (not admin.guild) or (not @checkAdmin admin) or (@checkAdmin player)
    @guildHash[player.guild].remove player

  disband: (player) ->
    return -1 if @guildHash[player.guild].leader isnt player.identifier
    guild = @guildHash[player.guild]
    _.each guild.invites, ((identifier) -> @invites[identifier] = _.without @invites[identifier], player.guild), @
    _.each guild.members, ((member) ->
      (@game.playerManager.getPlayerById member.identifier).guild = null
      (@game.playerManager.getPlayerById member.identifier).save()), @
    @guilds = _.reject @guilds, {name: guild.name}
    delete @guildHash[guild.name]
    @db.remove {name: guild.name}

module.exports = exports = GuildManager
