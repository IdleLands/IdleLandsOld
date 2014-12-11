
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
    @autoUpgrade = no
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

  pullOutStatsFrom: (base) ->
    stats = _.omit base, ["level", "name", "class", "_id"]
    [stats.type, stats.class, stats.name] = ["pet essence", "newbie", "pet essence"]
    stats

  canEquip: (item) ->
    # are all slots filled?
    itemsInSlot = (_.find @equipment, {type: item.type}).length
    return no if itemsInSlot >= PetData[@type].slots[item.type]

    # if not, we just have to make sure it's within our current parameters for equipping
    item.score() < @calc.itemFindRange()

  equip: (item) ->
    @removeFromInventory item
    @equipment.push item

  unequip: (item) ->
    @addToInventory item
    @equipment = _.without @equipment, item

  findEquipped: (uid) ->
    _.findWhere @equipment, {uid: uid}

  gainXp: (xp) ->
    @xp.add xp
    @levelUp() if @xp.atMax()

  levelUp: ->
    @level.add 1
    @resetMaxXp()
    @xp.toMinimum()

  buildSaveObject: ->
    realCalc = _.omit @calc, 'self'
    calc = realCalc.base
    calcStats = realCalc.statCache
    badStats = [
      'petManager'
      'party'
      'personalities'
      'identifier'
      'calc'
      'spellsAffectedBy'
      'fled'
      '_events'
      'profession'
      '_id'
    ]
    ret = _.omit @, badStats
    ret._baseStats = calc
    ret._statCache = calcStats
    ret

  increaseStat: (stat) ->
    @scaleLevel[stat]++
    @petManager.configurePet @

  feedOn: (gold) ->
    config = PetData[@type]

    xp = gold * config.scale.xpPerGold[@scaleLevel.xpPerGold]

    @gainXp xp

    xp

  getOwner: ->
    @petManager.game.playerManager.getPlayerByName @owner.name

  save: ->
    @petManager.save @buildSaveObject()

  addToItemFindTimer: (time) ->
    @nextItemFind.setSeconds @nextItemFind.getSeconds() + time

  updateItemFind: ->
    config = PetData[@type]
    findTime = config.scale.itemFindTimeDuration[@scaleLevel.itemFindTimeDuration]
    @nextItemFind = new Date()
    @addToItemFindTimer findTime

  sellItem: (item, findLowest = @smartSell) ->
    config = PetData[@type]

    if findLowest
      lowestScoreItem = _.min @inventory, (item) -> item.score()

      if lowestScoreItem.score() < item.score()
        @inventory.push item
        @inventory = _.without @inventory, lowestScoreItem
        item = lowestScoreItem

    sellBonus = (@calc.itemSellMultiplier item) + config.scale.itemSellMultiplier[@scaleLevel.itemSellMultiplier]
    value = Math.max 1, Math.floor item.score() * sellBonus
    @gold.add value

    value

  actuallyFindItem: ->
    config = PetData[@type]
    bonus = config.scale.itemFindBonus[@scaleLevel.itemFindBonus]
    item = @petManager.game.equipmentGenerator.generateItem null, bonus

    return if not item

    if @canAddToInventory()
      @addToInventory item

    else
      @sellItem item

  addToInventory: (item) ->
    @inventory.push item

  removeFromInventory: (item) ->
    @inventory = _.without @inventory, item

  canAddToInventory: ->
    config = PetData[@type]
    size = config.scale.inventory[@scaleLevel.inventory]

    @inventory.length < size

  handleItemFind: ->
    config = PetData[@type]
    findTime = config.scale.itemFindTimeDuration[@scaleLevel.itemFindTimeDuration]
    return if not findTime

    @updateItemFind() if not @nextItemFind

    if new Date() > @nextItemFind
      @actuallyFindItem()
      @addToItemFindTimer findTime

  takeTurn: ->
    @handleItemFind()
    @save()

module.exports = exports = Pet
