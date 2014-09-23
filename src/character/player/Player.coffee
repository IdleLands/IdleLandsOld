
Character = require "../base/Character"
RestrictedNumber = require "restricted-number"
MessageCreator = require "../../system/MessageCreator"
Constants = require "../../system/Constants"
Equipment = require "../../item/Equipment"
_ = require "underscore"
Personality = require "../base/Personality"

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
      @changeProfession "Generalist", yes
      @levelUp yes
      @generateBaseEquipment()

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

    @playerManager.game.broadcast MessageCreator.genericMessage message

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

    if not dest.map
      console.error "ERROR. No dest.map at #{@x},#{@y} in #{@map}"
      return

    @map = dest.map
    @x = dest.x
    @y = dest.y

    message = ""

    dest.destName = dest.map if not dest.destName

    switch dest.movementType
      when "ascend" then message = "<player.name>#{@name}</player.name> has ascended to <event.transfer.destination>#{dest.destName}</event.transfer.destination>."
      when "descend" then message = "<player.name>#{@name}</player.name> has descended to <event.transfer.destination>#{dest.destName}</event.transfer.destination>."
      when "fall" then message = "<player.name>#{@name}</player.name> has fallen from <event.transfer.from>#{dest.fromName}</event.transfer.from> to <event.transfer.destination>#{dest.destName}</event.transfer.destination>!"

    @emit "explore.transfer.#{dest.movementType}", @

    @playerManager.game.broadcast MessageCreator.genericMessage message

  handleTile: (tile) ->
    switch tile.object?.type
      when "Trainer" then @handleTrainerOnTile tile
      when "Teleport" then @handleTeleport tile

    if tile.object?.forceEvent
      @playerManager.game.eventHandler.doEventForPlayer @name, tile.object.forceEvent

  pickRandomTile: ->
    @ignoreDir = [] if not @ignoreDir
    @stepCooldown = 0 if not @stepCooldown


    dir = randomDir() while dir in @ignoreDir

    randomDir = -> chance.integer({min: 1, max: 100})
    switch
      when 1  <=  randomDir <=  80      then dir = @lastDir
      when 81 <=  randomDir <=  84      then dir = (@lastDir + 1) %% 8
      when 85 <=  randomDir <=  87      then dir = (@lastDir + 2) %% 8
      when randomDir = 88               then dir = (@lastDir + 3) %% 8
      when randomDir = 89               then dir = (@lastDir + 4) %% 8
      when randomDir = 90               then dir = (@lastDir + 5) %% 8
      when 91 <=  randomDir <=  93      then dir = (@lastDir + 6) %% 8
      when 94 <=  randomDir <=  97      then dir = (@lastDir + 7) %% 8
    else dir = 9

    [(@num2dir dir, @x, @y), dir]

  moveAction: ->
    lookAtTile = @playerManager.game.world.maps[@map].getTile.bind @playerManager.game.world.maps[@map]
    [newLoc, dir] = @pickRandomTile()

    try
      tile = lookAtTile newLoc.x,newLoc.y

      while (tile.blocked and chance.bool likelihood: 95)
        [newLoc, dir] = @pickRandomTile()
        tile = lookAtTile newLoc.x, newLoc.y

      if not tile.blocked
        @x = newLoc.x
        @y = newLoc.y
        @lastDir = dir
        @ignoreDir = []

      else
        @lastDir = null
        @ignoreDir.push dir

        @emit 'explore.hit.wall', @

      @emit 'explore.walk', @
      @emit "explore.walk.#{tile.terrain}".toLowerCase(), @

      @handleTile tile

      @stepCooldown--

    catch
      @x = @y = 10
      @map = "Norkos"

  changeProfession: (to, suppress = no) ->
    @profession?.unload? @
    oldProfessionName = @professionName
    professionProto = require "../classes/#{to}"
    @profession = new professionProto()
    @professionName = professionProto.name
    @profession.load @
    @playerManager.game.broadcast MessageCreator.genericMessage "<player.name>#{@name}</player.name> is now a <player.class>#{to}</player.class>!" if not suppress
    @emit "player.profession.change", @, oldProfessionName, @professionName

    @recalculateStats()

  calculateYesPercent: ->
    Math.min 100, (Math.max 0, Constants.defaults.player.defaultYesPercent + @personalityReduce 'calculateYesPercentBonus')

  getGender: ->
    "male"

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

  takeTurn: ->
    @moveAction()
    @possiblyDoEvent()
    @possiblyLeaveParty()
    @save()

  save: ->
    return if not @playerManager
    @playerManager.savePlayer @

  gainGold: (gold) ->
    if _.isNaN gold
      console.error "BAD GOLD VALUE GOTTEN SOMEHOW"
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

  levelUp: (suppress = no) ->
    return if not @playerManager or @level.getValue() is @level.maximum
    @level.add 1
    @playerManager.game.broadcast MessageCreator.genericMessage "<player.name>#{@name}</player.name> has attained level <player.level>#{@level.getValue()}</player.level>!" if not suppress
    @xp.maximum = @levelUpXpCalc @level.getValue()
    @xp.toMinimum()
    @emit "player.level.up", @
    @recalculateStats()

  setString: (type, val = '') ->
    @messages = {} if not @messages
    @messages[type] = val.substring 0, 24

module.exports = exports = Player
