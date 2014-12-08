
Character = require "../base/Character"
Equipment = require "../../item/Equipment"
RestrictedNumber = require "restricted-number"
_ = require "underscore"
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
    @autoSell = yes
    @scaleLevel = {}
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

  getOwner: ->
    @petManager.game.playerManager.getPlayerByName @owner.name

  save: ->
    @petManager.save @buildSaveObject()

  takeTurn: ->
    console.log "#{@name} taking turn"
    # do action, check if current time > expected time to finish event, if passes, do action and reset time?
    @save()

module.exports = exports = Pet
