
Character = require "../base/Character"
RestrictedNumber = require "restricted-number"
MessageCreator = require "../../system/handlers/MessageCreator"
Constants = require "../../system/utilities/Constants"
ConvenienceFunctions = require "../../system/utilities/ConvenienceFunctions"

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

    @base = "Norkos"
    @buildingLevels = {}
    @buildingLevelCosts = {}
    @buildingProps = {}
    @taxPercent = 0
    @initGold()
    @resetBuildings()

  resetBuildings: ->
    @currentlyBuilt = {sm: [], md: [], lg: []}

  hasBuilt: (findBuilding) ->
    ret = []
    ret.push @currentlyBuilt[size]... for size in ['sm', 'md', 'lg']
    _.contains ret, findBuilding

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

  subGold: (gold) ->
    @gold.sub gold

  addGold: (gold) ->
    initGold() unless @gold
    @gold.__current = 0 if _.isNaN @gold.getValue()
    @gold.add gold

  initGold: ->
    @gold = new RestrictedNumber 0, 9999999999, 0

  calcTax: (player) ->
    player.guildTax + @taxPercent

  collectTax: (player, gold) ->
    @addGold gold

    ##TAG:EVENT_PLAYER: gold.guildTax   | guildName, goldTaxed | Emitted when a guild collects tax from a member
    player.emit "player.gold.guildTax", @name, gold

  getGuildBaseName: ->
    @baseName = "Guild Hall - #{@name}"

  getGuildBase: ->
    @guildManager.game.world.maps[@getGuildBaseName()]

  buildBase: ->
    @guildManager.game.world.maps[@getGuildBaseName()] = new (require "../../map/guild-bases/#{@base}") @guildManager.game, @
    @reconstructBuildings()

  reconstructBuildings: ->
    base = @getGuildBase()

    @_validProps = {}

    _.each ['sm', 'md', 'lg'], (size) =>
      _.map base.instances[size], -> null
      _.each @currentlyBuilt[size], (building, i) =>
        return unless building
        inst = base.instances[size][i] = new (require "../../map/guild-buildings/#{building}") @guildManager.game, @
        base.build building, size, i, inst

        @_validProps[building] = inst.properties

  changeLeader: (identifier, newLeaderName) ->
    return Q {isSuccess: no, code: 50, message: "You aren't the leader!"} if @leader isnt identifier

    me = @guildManager.game.playerManager.getPlayerById identifier
    targetPlayer = @guildManager.game.playerManager.getPlayerByName newLeaderName
    return Q {isSuccess: no, code: 951, message: "That member is not online!"} unless targetPlayer
    return Q {isSuccess: no, code: 952, message: "That member is not in your guild!"} unless targetPlayer.guild is me.guild

    @leader = targetPlayer.identifier
    targetPlayer.guildStatus = 2
    me.guildStatus = 1
    meEntry = _.findWhere @members, {identifier: identifier}
    meEntry.isAdmin = yes

    @save()

    Q {isSuccess: yes, code: 953, message: "Successfully changed leadership to #{newLeaderName}!", guild: @buildSaveObject()}

  _setProperty: (building, property, value) ->
    property = ConvenienceFunctions.sanitizeStringNoPunctuation property
    value = ConvenienceFunctions.sanitizeString value.substring 0, 250

    @buildingProps[building] = {} unless @buildingProps[building]
    @buildingProps[building][property] = value

    @save()

    @reconstructBuildings()

  setProperty: (identifier, building, property, value) ->
    return Q {isSuccess: no, code: 50, message: "You aren't the leader!"} if @leader isnt identifier
    return Q {isSuccess: no, code: 80, message: "You don't have that building constructed!"} unless @hasBuilt building

    @_setProperty building, property, value

    Q {isSuccess: yes, code: 87, message: "Successfully set property \"#{property}\" for #{building} to \"#{value}\"!"}

  # It is intentional to return 0 if the building isn't built
  getBuildingLevel: (building) ->
    return 0 unless @hasBuilt building
    @buildingLevels[building]

  _upgrade: (building) ->
    @buildingLevels[building]++
    @save()

    @reconstructBuildings()

  upgrade: (identifier, building) ->
    return Q {isSuccess: no, code: 50, message: "You aren't the leader!"} if @leader isnt identifier
    return Q {isSuccess: no, code: 80, message: "You don't have that building constructed!"} unless @hasBuilt building

    #check cost
    ghLevel = @buildingLevels['GuildHall']
    nextLevel = @buildingLevels[building]+1
    return Q {isSuccess: no, code: 81, message: "You must first upgrade your Guild Hall!"} unless building is "GuildHall" or nextLevel <= ghLevel

    buildingProto = (require "../../map/guild-buildings/#{building}")
    cost = buildingProto.levelupCost nextLevel
    costDiff = cost - @gold.getValue()
    return Q {isSuccess: no, code: 708, message: "Your guild doesn't have enough gold! You need #{costDiff} more!"} if costDiff > 0

    @buildingLevelCosts[building] = buildingProto.levelupCost nextLevel+1
    @gold.sub cost
    @_upgrade building

    Q {isSuccess: yes, code: 82, message: "Successfully upgraded #{building} to level #{nextLevel}!"}

  _construct: (building, slot, size) ->
    @buildingLevels[building] = 1 unless @buildingLevels[building]
    @currentlyBuilt[size][slot] = building
    @reconstructBuildings()
    @save()

  construct: (identifier, newBuilding, slot) ->
    return Q {isSuccess: no, code: 50, message: "You aren't the leader!"} if @leader isnt identifier

    try
      building = require "../../map/guild-buildings/#{newBuilding}"
    catch e
      return Q {isSuccess: no, code: 708, message: "That building doesn't exist!"}

    base = @getGuildBase()
    return Q {isSuccess: no, code: 703, message: "You already built a #{newBuilding} in #{@base}!"} if _.contains @currentlyBuilt[building.size], newBuilding

    costDiff = base.costs.build[building.size] - @gold.getValue()
    return Q {isSuccess: no, code: 708, message: "Your guild doesn't have enough gold! You need #{costDiff} more!"} if costDiff > 0

    slot = Math.round slot
    return Q {isSuccess: no, code: 708, message: "That slot is out of range!"} if slot < 0 or slot > base.buildings[building.size].length-1

    @buildingLevelCosts[newBuilding] = building.levelupCost 2
    @gold.sub base.costs.build[building.size]
    @_construct newBuilding, slot, building.size

    Q {isSuccess: yes, code: 706, message: "Successfully built a #{newBuilding} in #{@name}'s #{@base} guild hall!"}

  _moveToBase: (@base) ->
    @resetBuildings()
    @buildBase()

    base = @getGuildBase()
    inBase = _.filter @guildManager.game.playerManager.players, (player) => player.map is @getGuildBaseName()
    _.each inBase, (player) ->
      player.x = base.startLoc[0]
      player.y = base.startLoc[1]

    @save()

  moveToBase: (identifier, newBase) ->
    return Q {isSuccess: no, code: 50, message: "You aren't the leader!"} if @leader isnt identifier
    return Q {isSuccess: no, code: 702, message: "Your base is already #{newBase}!"} if @base is newBase

    try
      base = require "../../map/guild-bases/#{newBase}"
    catch e
      return Q {isSuccess: no, code: 707, message: "That base doesn't exist!"}

    costDiff = base.costs.moveIn - @gold.getValue()
    return Q {isSuccess: no, code: 700, message: "Your guild doesn't have enough gold! You need #{costDiff} more!"} if costDiff > 0

    @gold.sub base.costs.moveIn
    @_moveToBase newBase

    Q {isSuccess: yes, code: 701, message: "You've successfully moved your base to #{newBase}!"}

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

      if player
        member._cache =
          online: yes
          level: player.level.getValue()
          class: player.professionName
          lastSeen: Date.now()
      else
        member._cache?.online = no

      # please don't remove, this is arcane but necessary.
      null

    @guildManager.buildGuildSaveObject @
    
module.exports = exports = Guild
