
Character = require "../base/Character"
RestrictedNumber = require "restricted-number"
MessageCreator = require "../../system/MessageCreator"
Constants = require "../../system/Constants"
_ = require "underscore"
Q = require "q"

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
    @members.push {identifier: player.identifier, isAdmin: no, name: player.name}
    player.guild = @name
    player.save()
    @avgLevel()
    Q()

  remove: (player) ->
    return -1 if not _.findWhere @members, {identifier: player.identifier}
    @members = _.reject @members, (member) -> member.identifier is player.identifier
    player.guild = null
    player.save()
    @avgLevel()

  promote: (leaderId, memberName) ->
    member = @guildManager.game.playerManager.getPlayerByName memberName

    return Q {isSuccess: no, code: 50, message: "You're not the leader of your guild!"} if leaderId isnt @leader
    return Q {isSuccess: no, code: 51, message: "That member does not exist!"} if not member
    return Q {isSuccess: no, code: 51, message: "That member is not in your guild!"} if member.guild isnt @name

    member.isAdmin = yes
    @save()

    Q {isSuccess: yes, code: 67, message: "Successfully promoted #{member.name}."}

  demote: (leaderId, memberName) ->
    member = @guildManager.game.playerManager.getPlayerByName memberName

    return Q {isSuccess: no, code: 50, message: "You're not the leader of your guild!"} if leaderId isnt @leader
    return Q {isSuccess: no, code: 51, message: "That member does not exist!"} if not member
    return Q {isSuccess: no, code: 51, message: "That member is not in your guild!"} if member.guild isnt @name

    member.isAdmin = no
    @save()

    Q {isSuccess: yes, code: 68, message: "Successfully demoted #{member.name}."}

  invitesLeft: ->
    @invitesAvailable = @cap() - (@members.length + @invites.length)

  avgLevel: ->

    query = [
      {$group: {_id: '$guild', level: {$avg:'$level.__current'}  }}
      {$match: {_id: @name}}
    ]

    @guildManager.game.playerManager.db.aggregate query, (e, result) =>
      @level = Math.round result[0].level
      @invitesLeft()
      @save()

  cap: -> 1 + (3*Math.floor ((@level or 1)/5))

  save: ->
    return if not @guildManager
    @invitesLeft()
    @guildManager.saveGuild @
    
module.exports = exports = Guild
