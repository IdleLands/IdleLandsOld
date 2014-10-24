
Character = require "../base/Character"
RestrictedNumber = require "restricted-number"
MessageCreator = require "../../system/MessageCreator"
Constants = require "../../system/Constants"
_ = require "underscore"
q = require "q"

Chance = require "chance"
chance = new Chance Math.random

class Guild

  constructor: (options) ->

    [@name, @leader] = [options.name, options.leader]
    @createDate = new Date()
    @members = []
    @invites = []

  add: (player) ->
    defer = q.defer()
    return if player.guild?
    @members.push {identifier: player.identifier, isAdmin: no, name: player.name}
    player.guild = @name
    player.save()
    @save()
    defer

  remove: (player) ->
    return -1 if not _.findWhere @members, {identifier: player.identifier}
    @members = _.reject @members, (member) -> member.identifier is player.identifier
    player.guild = null
    player.save()
    @save()

  promote: (leaderId, memberName) ->
    defer = q.defer()

    member = @guildManager.game.playerManager.getPlayerByName memberName

    if leaderId isnt @leader or not member
      defer.resolve {isSuccess: no, message: "You can't do that!"}
      return defer

    member.isAdmin = yes
    @save()

    defer.resolve {isSuccess: yes, message: "Successfully promoted #{member.name}."}

    defer

  demote: (leaderId, memberName) ->
    defer = q.defer()
    member = @guildManager.game.playerManager.getPlayerByName memberName

    if leaderId isnt @leader or not member
      defer.resolve {isSuccess: no, message: "You can't do that!"}
      return defer

    member.isAdmin = no
    @save()
    defer.resolve {isSuccess: yes, message: "Successfully demoted #{member.name}."}

    defer

  invitesLeft: ->
    @invitesAvailable = @cap() - (@members.length + @invites.length)

  avgLevel: ->
    @level = (_.reduce @members, ((total, member) -> total + (@guildManager.game.playerManager.getPlayerById member.identifier).level.getValue()), 0, @)/@members.length

  cap: -> 1 + 3*Math.floor @avgLevel()/5

  save: ->
    return if not @guildManager
    @avgLevel()
    @invitesLeft()
    @guildManager.saveGuild @
    
module.exports = exports = Guild
