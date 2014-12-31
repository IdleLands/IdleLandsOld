
Character = require "../base/Character"
Equipment = require "../../item/Equipment"
RestrictedNumber = require "restricted-number"
_ = require "lodash"
chance = new (require "chance")()
PetData = require "../../../config/pets.json"

class Pet extends Character

  constructor: (options) ->
    super options

    [@type, @attrs, @owner, @creator] = [options.type, options.attrs, options.owner, options.creator]

    @level = new RestrictedNumber 0, PetData[@type].scale.maxLevel[0], 0
    @gold = new RestrictedNumber 0, PetData[@type].scale.goldStorage[0], 0
    @xp = new RestrictedNumber 0, (@levelUpXpCalc 1), 0

    @gender = chance.gender().toLowerCase()
    @setClassTo 'Monster'

    @isMonster = yes
    @isPet = yes
    @isActive = yes
    @smartSell = yes
    @smartEquip = yes
    @smartSelf = no
    @scaleLevel = {}
    @inventory = []
    @lastInteraction = Date.now()
    @createdAt = Date.now()

  getGender: -> @gender

  setClassTo: (newClass = 'Monster') ->
    toClass = null
    toClassName = newClass

    try
      toClass = new (require "../classes/#{newClass}")()
    catch
      toClass = new (require "../classes/Monster")()
      toClassName = "Monster"

    @profession = toClass
    toClass.load @
    @professionName = toClassName

  equippedItemsOfType: (type) ->
    _.filter @equipment, (item) -> item.type is type

  canEquip: (item) ->
    # are all slots filled?
    itemsInSlot = (@equippedItemsOfType item.type).length
    return no if itemsInSlot >= PetData[@type].slots[item.type]

    # if not, we just have to make sure it's within our current parameters for equipping
    item.score() < @calc.itemFindRange()

  equip: (item) ->
    @removeFromInventory item
    @equipment.push item
    @recalculateStats()

  unequip: (item) ->
    @addToInventory item
    @equipment = _.without @equipment, item
    @recalculateStats()

  findEquipped: (uid) ->
    _.findWhere @equipment, {uid: uid}

  gainXp: (xp) ->
    @xp.add xp
    @levelUp() if @xp.atMax()

  gainGold: (gold) ->
    @gold.add gold

    @tryToUpgradeSelf()

  tryToUpgradeSelf: ->
    return if not @smartSelf

    config = PetData[@type]

    _.each (_.keys @scaleLevel), (stat) =>
      curLevel = @scaleLevel[stat]
      cost = config.scaleCost[stat][curLevel+1]

      if cost < @gold.getValue()
        @increaseStat stat
        @gold.sub cost

  tryToEquipToSelf: (item) ->
    return if not @smartEquip
    return if not PetData[@type].slots[item.type]
    return if not @canUseItem item
    return if not @canEquip item

    itemsInSlot = @equippedItemsOfType item.type
    if itemsInSlot.length >= PetData[@type].slots[item.type]
      lowestScoreItem = _.min itemsInSlot, (item) -> item.score()

      if lowestScoreItem.score() < item.score()
        @equip item
        @equipment = _.without @equipment, lowestScoreItem
        @sellItem lowestScoreItem

        return true

    else if itemsInSlot.length < PetData[@type].slots[item.type]
      @equip item

      return true

  levelUp: ->
    @level.add 1
    @resetMaxXp()
    @xp.toMinimum()
    @recalculateStats()

  tryToJoinCombat: ->
    chance.bool {likelihood: @getStatAtCurrentLevel 'battleJoinPercent'}

  buildSaveObject: ->
    @petManager.buildPetSaveObject @

  increaseStat: (stat) ->
    @scaleLevel[stat] = 0 if not @scaleLevel[stat]
    @scaleLevel[stat]++

    @updateItemFind() if stat is 'itemFindTimeDuration'

    @petManager.configurePet @

  goldToNextLevel: ->
    Math.round (@xp.maximum - @xp.getValue()) / @getStatAtCurrentLevel 'xpPerGold'

  feed: ->
    @levelUp()

  getOwner: ->
    @petManager.game.playerManager.getPlayerByName @owner.name

  save: ->
    @petManager.save @buildSaveObject()

  addToItemFindTimer: (time) ->
    @nextItemFind.setSeconds @nextItemFind.getSeconds() + time

  updateItemFind: ->
    findTime = @getStatAtCurrentLevel 'itemFindTimeDuration'
    @nextItemFind = new Date()
    @addToItemFindTimer findTime

  sellItem: (item, findLowest = @smartSell) ->
    if findLowest
      lowestScoreItem = _.min @inventory, (item) -> item.score()

      if lowestScoreItem.score() < item?.score()
        @inventory.push item
        @inventory = _.without @inventory, lowestScoreItem
        item = lowestScoreItem

    sellBonus = (@calc.itemSellMultiplier item) + @getStatAtCurrentLevel 'itemSellMultiplier'

    value = Math.max 1, Math.round item.score() * sellBonus
    @gainGold value

    value

  actuallyFindItem: ->
    bonus = @getStatAtCurrentLevel 'itemFindBonus'
    item = @petManager.game.equipmentGenerator.generateItem null, bonus

    return if not item

    return if @tryToEquipToSelf item

    if @canAddToInventory item
      @addToInventory item

    else
      @sellItem item, no

  addToInventory: (item) ->
    @inventory.push item

    @recalculateStats()

  removeFromInventory: (item) ->
    @inventory = _.without @inventory, item

    @recalculateStats()

  canUseItem: (item) ->
    item?.score() <= @getStatAtCurrentLevel 'maxItemScore'

  hasInventorySpace: ->
    @inventory.length < @getStatAtCurrentLevel 'inventory'

  canAddToInventory: (item) ->
    return no if not @canUseItem item
    @hasInventorySpace()

  handleItemFind: ->
    findTime = @getStatAtCurrentLevel 'itemFindTimeDuration'
    return if not findTime

    @updateItemFind() if not @nextItemFind

    if new Date() > @nextItemFind
      @actuallyFindItem()
      @addToItemFindTimer findTime

  hasEquipmentSlot: (slot) ->
    PetData[@type].slots[slot]

  getStatAtCurrentLevel: (stat) ->
    config = PetData[@type]
    config.scale[stat][@scaleLevel[stat]]

  takeTurn: ->
    @handleItemFind()
    @save()

module.exports = exports = Pet
