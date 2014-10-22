
Character = require "../base/Character"
RestrictedNumber = require "restricted-number"
MessageCreator = require "../../system/MessageCreator"
Constants = require "../../system/Constants"
_ = require "underscore"

Chance = require "chance"
chance = new Chance Math.random

class Guild

  constructor: (options) ->

    [@name, @leader] = [options.name, options.leader]
    @createDate = new Date()
    @members = []
    @invites = []

  add: (player) ->
    return if player.guild?
    @members.push {identifier: player.identifier, isAdmin: no}
    player.guild = @name
    player.save()
    @save()

  remove: (player) ->
    return -1 if not _.findWhere @members, {identifier: player.identifier}
    @members = _.reject @members, {identifier: player.identifier}
    player.guild = null
    player.save()
    @save()

  promote: (leaderId, memberId) ->
    return -1 if leaderId isnt @leader or not (_.findWhere @members, {identifier: memberId})
    (_.findWhere @members, {identifier: memberId}).isAdmin = yes
    @save()

  demote: (leaderId, memberId) ->
    return -1 if leaderId isnt @leader or not (_.findWhere @members, {identifier: memberId})
    (_.findWhere @members, {identifier: memberId}).isAdmin = no
    @save()

  invitesLeft: ->
    return @cap() - (@members.length + @invites.length)

  avgLevel: ->
    (_.reduce @members, ((total, member) -> total + (@guildManager.game.playerManager.getPlayerById member.identifier).level.getValue()), 0, @)/@members.length

  cap: -> 1 + 3*Math.floor @avgLevel()/5

  save: ->
    return if not @guildManager
    @guildManager.saveGuild @
    
module.exports = exports = Guild
