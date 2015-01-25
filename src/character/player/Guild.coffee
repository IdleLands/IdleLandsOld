
Character = require "../base/Character"
RestrictedNumber = require "restricted-number"
MessageCreator = require "../../system/handlers/MessageCreator"
Constants = require "../../system/utilities/Constants"
_ = require "lodash"
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
    # Adding assumes that a player is online, i.e. they have accepted an invite.
    # Therefore, this function can use the player object directly.

    return if player.guild?
    @members.push {identifier: player.identifier, isAdmin: no, name: player.name}
    player.guild = @name
    player.guildStatus = 0
    player.save()
    @avgLevel()
    @notifyAllPossibleMembers "#{player.name} has joined the guild (\"#{@name}\")!"
    Q()

  remove: (playerName) ->
    # Removing a player should work even when the player is offline.
    # Therefore, this uses the player's name in case it cannot be retrieved (player is offline).

    memberEntry = _.findWhere @members, {name: playerName}
    @members = _.without @members, memberEntry

    # In the event that a player is online, modify their guild status and save the player.
    # If the player is offline, update the database directly.

    player = @guildManager.game.playerManager.getPlayerByName(playerName)
    if player?
      player.guild = null
      player.guildStatus = -1
      player.save()
    else
      @guildManager.game.playerManager.db.update {name: playerName}, {$set:{guild: null}}, {}, (e) =>
        @guildManager.game.errorHandler?.captureException e if e

    @notifyAllPossibleMembers "#{playerName} was removed from the guild (\"#{@name}\")."

    @avgLevel()

  promote: (leaderId, memberName) ->
    member = @guildManager.game.playerManager.getPlayerByName memberName
    memberEntry = _.findWhere @members, {name: memberName}

    return Q {isSuccess: no, code: 69, message: "You can't do that to the leader!"} if leaderId is memberEntry.identifier
    return Q {isSuccess: no, code: 50, message: "You're not the leader of your guild!"} if leaderId isnt @leader
    return Q {isSuccess: no, code: 51, message: "That member is not in your guild!"} if not memberEntry

    @notifyAllPossibleMembers "#{memberName} was promoted (\"#{@name}\")."

    memberEntry.isAdmin = yes
    member?.guildStatus = 1

    @save()

    Q {isSuccess: yes, code: 67, message: "Successfully promoted #{memberName}.", guild: @buildSaveObject()}

  demote: (leaderId, memberName) ->
    member = @guildManager.game.playerManager.getPlayerByName memberName
    memberEntry = _.findWhere @members, {name: memberName}

    return Q {isSuccess: no, code: 69, message: "You can't do that to the leader!"} if leaderId is memberEntry.identifier
    return Q {isSuccess: no, code: 50, message: "You're not the leader of your guild!"} if leaderId isnt @leader
    return Q {isSuccess: no, code: 51, message: "That member is not in your guild!"} if not memberEntry

    @notifyAllPossibleMembers "#{memberName} was demoted (\"#{@name}\")."

    memberEntry.isAdmin = no
    member?.guildStatus = 0

    @save()

    Q {isSuccess: yes, code: 68, message: "Successfully demoted #{memberName}.", guild: @buildSaveObject()}

  setTax: (leaderId, newTax) ->
    newTax = Math.round Math.min 15, Math.max 0, newTax
    return Q {isSuccess: no, code: 50, message: "You're not the leader of your guild!"} if leaderId isnt @leader
    @taxPercent = newTax
    @save()

    @notifyAllPossibleMembers "The tax rate of \"#{@name}\" is now #{@taxPercent}%."
    Q {isSuccess: yes, code: 70, message: "Successfully set the tax rate of \"#{@name}\" to #{newTax}%!", guild: @buildSaveObject()}

  calcTax: (player) ->
    player.guildTax + @taxPercent

  collectTax: (player, gold) ->
    @gold.add gold
    player.emit "player.gold.guildTax", @name, gold

  notifyAllPossibleMembers: (message) ->
    _.each @members, (member) =>
      player = @guildManager.game.playerManager.getPlayerById member.identifier
      return if not player
      @guildManager.game.eventHandler.addEventToDb message, player, 'guild'

  invitesLeft: ->
    @invitesAvailable = @cap() - (@members.length + @invites.length)

  avgLevel: ->

    oldLevel = @level

    query = [
      {$group: {_id: '$guild', level: {$avg:'$level.__current'}  }}
      {$match: {_id: @name}}
    ]

    @guildManager.game.playerManager.db.aggregate query, (e, result) =>
      @level = Math.round result[0].level
      @invitesLeft()
      @save()

      levelDiff = @level-oldLevel
      @notifyAllPossibleMembers "Your guild, \"#{@name}\" is now level #{@level} [change: #{if levelDiff > 0 then "+" else ""}#{levelDiff}]." if levelDiff isnt 0 and not _.isNaN levelDiff

  cap: -> 1 + (3*Math.floor ((@level or 1)/5))

  save: ->
    return if not @guildManager
    @invitesLeft()
    @guildManager.saveGuild @

  buildSaveObject: ->
    _.each @members, (member) =>
      player = @guildManager.game.playerManager.getPlayerById member.identifier

      isOnline = player?

      if isOnline
        member._cache =
          online: isOnline
          level: player.level.getValue()
          class: player.professionName
          lastSeen: Date.now()
      else
        member._cache?.online = no

    @guildManager.buildGuildSaveObject @
    
module.exports = exports = Guild
