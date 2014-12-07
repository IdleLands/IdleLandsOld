
Character = require "../base/Character"
Equipment = require "../../item/Equipment"
RestrictedNumber = require "restricted-number"
_ = require "underscore"
chance = new (require "chance")()
PetData = require "../../../config/pets.json"

class Pet extends Character

  constructor: (options) ->

    return if not options.type

    super options

    @level = new RestrictedNumber 0, PetData[type].scale.maxLevel[0], 0
    @gold = new RestrictedNumber 0, PetData[type].scale.goldStorage[0], 0
    @lastInteraction = new Date()
    @gender = chance.gender().toLowerCase()
    @xp = new RestrictedNumber 0, (@levelUpXpCalc level), 0
    @setClassTo 'Monster'
    @gender = chance.gender().toLowerCase()
    @isMonster = yes
    @isPet = yes
    @isActive = yes
    @autoSell = yes
    @scaleLevel = {}
    @lastInteraction = Date.now()

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
    myItem = _.findWhere @equipment, {type: item.type}
    return if not myItem
    score = @calc.itemScore item
    myScore = @calc.itemScore myItem
    realScore = item.score()

    score > myScore and realScore < @calc.itemFindRange()

  save: ->

  takeTurn: ->
    # do action, check if current time > expected time to finish event, if passes, do action and reset time?

module.exports = exports = Pet
