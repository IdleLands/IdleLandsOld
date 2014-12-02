
Character = require "../base/Character"
RestrictedNumber = require "restricted-number"
MessageCreator = require "../../system/MessageCreator"
Constants = require "../../system/Constants"
Equipment = require "../../item/Equipment"
_ = require "underscore"
Q = require "q"
Personality = require "../base/Personality"
requireDir = require "require-dir"
regions = requireDir "../regions"

PushBullet = require "pushbullet"

Chance = require "chance"
chance = new Chance Math.random

class Player extends Character

  isBusy: false

  constructor: (player) ->
    super player

  initialize: ->
    if not @xp
      @xp = new RestrictedNumber 0, (@levelUpXpCalc 0), 0
      @gold = new RestrictedNumber 0, 9999999999, 0
      @x = 10
      @y = 10
      @map = 'Norkos'

      norkosClasses = ['Generalist', 'Mage', 'Fighter', 'Cleric']
      @changeProfession (_.sample norkosClasses), yes
      @levelUp yes
      @generateBaseEquipment()
      @overflow = []
      @lastLogin = new Date()
      @gender = "female"
      @priorityPoints = {dex: 1, str: 1, agi: 1, wis: 1, con: 1, int: 1}
      @calc.itemFindRange()

  generateBaseEquipment: ->
    @equipment = [
      new Equipment {type: "body",    class: "newbie", name: "Tattered Shirt", con: 1}
      new Equipment {type: "feet",    class: "newbie", name: "Cardboard Shoes", dex: 1}
      new Equipment {type: "finger",  class: "newbie", name: "Twisted Wire", int: 1}
      new Equipment {type: "hands",   class: "newbie", name: "Pixelated Gloves", str: 1}
      new Equipment {type: "head",    class: "newbie", name: "Miniature Top Hat", wis: 1}
      new Equipment {type: "legs",    class: "newbie", name: "Leaf", agi: 1}
      new Equipment {type: "neck",    class: "newbie", name: "Old Brooch", wis: 1, int: 1}
      new Equipment {type: "mainhand",class: "newbie", name: "Empty and Broken Ale Bottle", str: 1, con: -1}
      new Equipment {type: "offhand", class: "newbie", name: "Chunk of Rust", dex: 1, str: 1}
      new Equipment {type: "charm",   class: "newbie", name: "Ancient Bracelet", con: 1, dex: 1}
    ]

  setPushbulletKey: (key) ->
    @pushbulletApiKey = key
    @pushbulletSend "This is a test for Idle Lands" if key
    Q {isSuccess: yes, code: 99, message: "Your PushBullet API key has been #{if key then "added" else "removed"} successfully. You should also have gotten a test message!"}

  pushbulletSend: (message, link = null) ->
    pushbullet = new PushBullet @pushbulletApiKey if @pushbulletApiKey
    return if not pushbullet

    pushbullet.devices (e, res) ->
      _.each res?.devices, (device) ->
        if link
          pushbullet.link device.iden, message, link (e, res) ->
        else
          pushbullet.note device.iden, 'IdleLands', message, (e, res) ->

  handleGuildStatus: ->

    if not @guild
      @guildStatus = -1

    else if @guild
      gm = @playerManager.game.guildManager

      gm.waitForGuild().then =>
        guild = gm.guildHash[@guild]

        if guild.leader is @identifier
          @guildStatus = 2
          guild.leaderName = @name
          guild.save()

        else if _.findWhere guild.members, {identifier: @identifier, isAdmin: yes}
          @guildStatus = 1

        else
          @guildStatus = 0

  manageOverflow: (option, slot) ->
    defer = Q.defer()

    @overflow = [] if not @overflow

    cleanOverflow = =>
      @overflow = _.compact _.reject @overflow, (item) -> item?.name is "empty"

    switch option
      when "add"
        @addOverflow slot, defer

      when "swap"
        @swapOverflow slot, defer
        cleanOverflow()

      when "sell"
        @sellOverflow slot, defer
        cleanOverflow()

    @recalculateStats()

    defer.promise

  forceIntoOverflow: (item) ->

    # no params = no problems
    do @manageOverflow
    @overflow.push item

  addOverflow:  (slot, defer) ->
    if not (slot in ["body","feet","finger","hands","head","legs","neck","mainhand","offhand","charm"])
      return defer.resolve {isSuccess: no, code: 40, message: "That slot is invalid."}

    if @overflow.length is Constants.defaults.player.maxOverflow
      return defer.resolve {isSuccess: no, code: 41, message: "Your inventory is currently full!"}

    currentItem = _.findWhere @equipment, {type: slot}

    if currentItem.name is "empty"
      return defer.resolve {isSuccess: no, code: 42, message: "You can't add empty items to your inventory!"}

    @overflow.push currentItem
    @equipment = _.without @equipment, currentItem
    @equipment.push new Equipment {type: slot, name: "empty"}
    defer.resolve {isSuccess: yes, code: 45, message: "Successfully added #{currentItem.name} to your inventory in slot #{@overflow.length-1}.", player: @buildRESTObject()}

  swapOverflow: (slot, defer) ->
    if not @overflow[slot]
      return defer.resolve {isSuccess: no, code: 43, message: "You don't have anything in that inventory slot."}

    current = _.findWhere @equipment, {type: @overflow[slot].type}
    inOverflow = @overflow[slot]

    @equipment = _.without @equipment, current
    @equipment.push inOverflow

    @overflow[slot] = current

    defer.resolve {isSuccess: yes, code: 47, message: "Successfully swapped #{current.name} with #{inOverflow.name} (slot #{slot}).", player: @buildRESTObject()}

  sellOverflow: (slot, defer) ->
    curItem = @overflow[slot]
    if (not curItem) or (curItem.name is "empty")
      return defer.resolve {isSuccess: yes, code: 44, message: "That item is not able to be sold!"}

    salePrice = Math.max 2, @calcGoldGain Math.round curItem.score()*@calc.itemSellMultiplier curItem
    @gainGold salePrice

    @overflow[slot] = null
    defer.resolve {isSuccess: yes, code: 46, message: "Successfully sold #{curItem.name} for #{salePrice} gold.", player: @buildRESTObject()}

  handleTrainerOnTile: (tile) ->
    return if @isBusy or @stepCooldown > 0
    @isBusy = true
    className = tile.object.name
    message = "<player.name>#{@name}</player.name> has met with the <player.class>#{className}</player.class> trainer!"
    if @professionName is className
      message += " Alas, <player.name>#{@name}</player.name> is already a <player.class>#{className}</player.class>!"
      @isBusy = false
      @emit "player.trainer.isAlready", @, className
      @stepCooldown = 10

    @playerManager.game.eventHandler.broadcastEvent {message: message, player: @, type: 'profession'}

    if @professionName isnt className and (chance.bool likelihood: @calc.classChangePercent className)
      @playerManager.game.eventHandler.doYesNo {}, @, (result) =>
        @isBusy = false
        if not result
          @emit "player.trainer.ignore", @, className
          return

        @emit "player.trainer.speak", @, className
        @changeProfession className

  handleTeleport: (tile) ->
    return if @stepCooldown > 0
    @stepCooldown = 30
    dest = tile.object.properties
    dest.x = parseInt dest.destx
    dest.y = parseInt dest.desty

    newLoc = dest

    if not dest.map and not dest.toLoc
      console.error "ERROR. No dest.map at #{@x},#{@y} in #{@map}"
      return

    if not dest.movementType
      console.error "ERROR. No dest.movementType at #{@x},#{@y} in #{@map}"
      return
      
    dest.movementType = dest.movementType.toLowerCase()

    eventToTest = "#{dest.movementType}Chance"

    prob = @calc[eventToTest]()

    return if not chance.bool({likelihood: prob})

    handleLoc = no

    dest.fromName = @map if not dest.fromName
    dest.destName = dest.map if not dest.destName

    if dest.toLoc
      newLoc = @playerManager.game.gmCommands.lookupLocation dest.toLoc
      @map = newLoc.map
      @x = newLoc.x
      @y = newLoc.y
      handleLoc = yes
      dest.destName = newLoc.formalName

    else
      @map = newLoc.map
      @x = newLoc.x
      @y = newLoc.y

    @oldRegion = @mapRegion
    @mapRegion = newLoc.region

    message = ""

    switch dest.movementType
      when "ascend" then    message = "<player.name>#{@name}</player.name> has ascended to <event.transfer.destination>#{dest.destName}</event.transfer.destination>."
      when "descend" then   message = "<player.name>#{@name}</player.name> has descended to <event.transfer.destination>#{dest.destName}</event.transfer.destination>."
      when "fall" then      message = "<player.name>#{@name}</player.name> has fallen from <event.transfer.from>#{dest.fromName}</event.transfer.from> to <event.transfer.destination>#{dest.destName}</event.transfer.destination>!"
      when "teleport" then  message = "<player.name>#{@name}</player.name> was teleported from <event.transfer.from>#{dest.fromName}</event.transfer.from> to <event.transfer.destination>#{dest.destName}</event.transfer.destination>!"

    if @hasPersonality "Wheelchair"
      if dest.movementType is "descend"
        message = "<player.name>#{@name}</player.name> went crashing down in a wheelchair to <event.transfer.destination>#{dest.destName}</event.transfer.destination>."

    @emit "explore.transfer", @, @map
    @emit "explore.transfer.#{dest.movementType}", @, @map

    @playerManager.game.eventHandler.broadcastEvent {message: message, player: @, type: 'explore'}

    @handleTile @getTileAt() if handleLoc

  handleTile: (tile) ->
    switch tile.object?.type
      when "Boss" then @handleBossBattle tile.object.name
      when "Teleport" then @handleTeleport tile
      when "Trainer" then @handleTrainerOnTile tile
      when "Treasure" then @handleTreasure tile.object.name

    if tile.object?.forceEvent
      @playerManager.game.eventHandler.doEventForPlayer @name, tile.object.forceEvent

  handleTreasure: (treasure) ->
    @playerManager.game.treasureFactory.createTreasure treasure, @

  handleBossBattle: (bossName) ->
    @playerManager.game.eventHandler.bossBattle @, bossName

  pickRandomTile: ->
    @ignoreDir = [] if not @ignoreDir
    @stepCooldown = 0 if not @stepCooldown

    randomDir = -> chance.integer({min: 1, max: 9})

    dir = randomDir()
    dir = randomDir() while dir in @ignoreDir

    dir = if chance.bool {likelihood: if @hasPersonality 'Drunk' then 40 else 80} then @lastDir else dir

    [(@num2dir dir, @x, @y), dir]

  getTileAt: (x = @x, y = @y) ->
    lookAtTile = @playerManager.game.world.maps[@map].getTile.bind @playerManager.game.world.maps[@map]
    lookAtTile x,y

  getRegion: ->
    regions[@getTileAt().region.replace(/\s/g, '')]

  moveAction: (currentStep) ->
    [newLoc, dir] = @pickRandomTile()

    try
      tile = @getTileAt newLoc.x,newLoc.y

      while (tile.blocked and chance.bool likelihood: if @hasPersonality 'Drunk' then 80 else 95)
        [newLoc, dir] = @pickRandomTile()
        tile = @getTileAt newLoc.x, newLoc.y

      if not tile.blocked
        @x = newLoc.x
        @y = newLoc.y
        @lastDir = dir
        @ignoreDir = []

      else
        @lastDir = null
        @ignoreDir.push dir

        @emit 'explore.hit.wall', @

      @oldRegion = @mapRegion
      @mapRegion = tile.region

      @emit 'explore.walk', @
      @emit "explore.walk.#{tile.terrain or "void"}".toLowerCase(), @

      console.error @x,@y,@map, "INVALID TILE" if not tile.terrain

      @handleTile tile

      @stepCooldown--

      @gainXp @calcXpGain 10 if currentStep < 5

    catch e
      console.error "BAD LOCATION",e.stack
      @x = @y = 10
      @map = "Norkos"

  changeProfession: (to, suppress = no) ->
    @profession?.unload? @
    oldProfessionName = @professionName
    professionProto = require "../classes/#{to}"
    @profession = new professionProto()
    @professionName = professionProto.name
    @profession.load @

    message = "<player.name>#{@name}</player.name> is now a <player.class>#{to}</player.class>!"

    @playerManager.game.eventHandler.broadcastEvent {message: message, player: @, type: 'profession'} if not suppress

    @emit "player.profession.change", @, oldProfessionName, @professionName

    @recalculateStats()

  calculateYesPercent: ->
    Math.min 100, (Math.max 0, Constants.defaults.player.defaultYesPercent + @personalityReduce 'calculateYesPercentBonus')

  getGender: ->
    if @gender then @gender else "female"

  setGender: (newGender) ->
    @gender = newGender.substring 0,15
    @gender = 'indeterminate' if not @gender
    Q {isSuccess: yes, code: 97, message: "Your gender is now #{@gender}."}

  score: ->
    @calc.partyScore()

  possiblyDoEvent: ->
    event = Constants.pickRandomEvent @
    return if not event
    @playerManager.game.eventHandler.doEvent event, @, ->{} #god damned code collapse

  possiblyLeaveParty: ->
    return if not @party
    return if @party.currentBattle
    return if not chance.bool {likelihood: @calc.partyLeavePercent()}
    @party.playerLeave @

  checkShop: ->
    @shop = null if @shop and ((not @getRegion()?.shopSlots?()) or (@getRegion()?.name isnt @shop.region))
    @shop = @playerManager.game.shopGenerator.regionShop @ if not @shop and @getRegion()?.shopSlots?()

  buyShop: (slot) ->
    if not @shop.slots[slot]
      return Q {isSuccess: no, code: 123, message: "The shop doesn't have an item in slot #{slot}."}
    if @shop.slots[slot].price > @gold.getValue()
      return Q {isSuccess: no, code: 124, message: "That item costs #{@shop.slots[slot].price} gold, but you only have #{@gold.getValue()} gold."}

    resolved = Q {isSuccess: yes, code: 125, message: "Successfully purchased #{@shop.slots[slot].item.name} for #{@shop.slots[slot].price} gold.", player: @buildRESTObject()}

    @gold.sub @shop.slots[slot].price

    current = _.findWhere @equipment, {type: @shop.slots[slot].item.type}
    @equipment = _.without @equipment, current
    @equipment.push @shop.slots[slot].item
    @shop.slots[slot] = null
    @shop.slots = _.compact @shop.slots
    @save()

    resolved

  takeTurn: ->
    steps = Math.max 1, @calc.haste()
    @moveAction steps while steps-- isnt 0
    @possiblyDoEvent()
    @possiblyLeaveParty()
    @checkShop()
    @save()
    @

  save: ->
    return if not @playerManager
    @playerManager.savePlayer @

  gainGold: (gold) ->
    if _.isNaN gold
      console.error "BAD GOLD VALUE GOTTEN SOMEHOW"
      console.error new Error().stack

      gold = 1

    if gold > 0
      @emit "player.gold.gain", @, gold
    else
      @emit "player.gold.lose", @, gold

    @gold.add gold

  gainXp: (xp) ->
    if xp > 0
      @emit "player.xp.gain", @, xp
    else
      @emit "player.xp.lose", @, xp

    @xp.set 0 if _.isNaN @xp.__current
    @xp.add xp

    @levelUp() if @xp.atMax()

  buildRESTObject: ->
    @playerManager.buildPlayerSaveObject @

  levelUp: (suppress = no) ->
    return if not @playerManager or @level.getValue() is @level.maximum
    @level.add 1
    message = "<player.name>#{@name}</player.name> has attained level <player.level>#{@level.getValue()}</player.level>!"
    @xp.maximum = @levelUpXpCalc @level.getValue()
    @xp.toMinimum()
    @recalculateStats()
    @playerManager.game.eventHandler.broadcastEvent {message: message, player: @, type: 'levelup'} if not suppress
    @recalcGuildLevel()
    @emit "player.level.up", @

    @playerManager.addForAnalytics @

  recalcGuildLevel: ->
    return if not @guild

    @playerManager.game.guildManager.guildHash[@guild].avgLevel()

  setString: (type, val = '') ->
    @messages = {} if not @messages
    @messages[type] = val.substring 0, 99
    if not @messages[type]
      delete @messages[type]
      return Q {isSuccess: yes, code: 95, message: "Successfully updated your string settings. Removed string type \"#{type}.\""}
    Q {isSuccess: yes, code: 95, message: "Successfully updated your string settings. String \"#{type}\" is now: #{if val then val else 'empty!'}"}

  checkAchievements: (silent = no) ->
    oldAchievements = _.compact _.clone @achievements
    @achievements = []

    achieved = @playerManager.game.achievementManager.getAllAchievedFor @

    stringCurrent = _.map oldAchievements, (achievement) -> achievement.name
    stringAll = _.map achieved, (achievement) -> achievement.name

    newAchievements = _.difference stringAll, stringCurrent

    _.each newAchievements, (achievementName) =>
      achievement = _.findWhere achieved, name: achievementName
      @achievements.push achievement
      if not silent
        message = "<player.name>#{@name}</player.name> has achieved <event.achievement>#{achievementName}</event.achievement> (#{achievement.desc} | #{achievement.reward})"
        @playerManager.game.eventHandler.broadcastEvent {message: message, player: @, type: 'achievement'} if not silent

    @achievements = achieved

  itemPriority: (item) ->
    if not @priorityPoints
      @priorityPoints = {dex: 1, str: 1, agi: 1, wis: 1, con: 1, int: 1}
    ret = 0
    ret += item[stat]*@priorityPoints[stat]*Constants.defaults.player.priorityScale for stat in ["dex", "str", "agi", "wis", "con", "int"]
    ret

  priorityTotal: ->
    _.reduce @priorityPoints, ((total, stat) -> total + stat), 0

  addPriority:  (stat, points) ->
    if not @priorityPoints
      @priorityPoints = {dex: 1, str: 1, agi: 1, wis: 1, con: 1, int: 1}

    points = if _.isNumber points then points else parseInt points
    points = Math.round points

    if points is 0
      return Q {isSuccess: no, code: 110, message: "You didn't specify a valid priority point amount."}

    if not (stat in ["dex", "str", "agi", "wis", "con", "int"])
      return Q {isSuccess: no, code: 111, message: "That stat is invalid."}

    if points > 0 and @priorityTotal() + points > Constants.defaults.player.priorityTotal
      return Q {isSuccess: no, code: 112, message: "Not enough priority points remaining."}

    if points < 0 and @priorityPoints[stat] + points < 0
      return Q {isSuccess: no, code: 112, message: "Not enough priority points to remove."}

    @priorityPoints[stat] += points
    if points > 0
      return Q {isSuccess: yes, code: 113, message: "Successfully added #{points} to your #{stat} priority."}

    else
      return Q {isSuccess: yes, code: 113, message: "Successfully removed #{-points} from your #{stat} priority."}

module.exports = exports = Player
