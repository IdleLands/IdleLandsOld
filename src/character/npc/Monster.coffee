
Character = require "../base/Character"
Equipment = require "../../item/Equipment"
RestrictedNumber = require "restricted-number"
_ = require "lodash"
chance = new (require "chance")()

class Monster extends Character

  constructor: (options) ->
    baseStatItem = @pullOutStatsFrom options
    level = options.level
    super options

    @level = new RestrictedNumber 0, 1000, 0

    @gender = chance.gender().toLowerCase()

    @level.set level

    maxXp = @levelUpXpCalc level
    @xp = new RestrictedNumber 0, maxXp, (chance.integer min:0, max:maxXp)
    @generateBaseEquipment()
    @setClassTo options['class']
    @equipment.push new Equipment baseStatItem
    @isMonster = yes

  getGender: -> @gender

  setClassTo: (newClass = 'Monster') ->
    toClass = null
    toClassName = newClass

    (toClassName = if chance.bool() then 'MagicalMonster' else 'Monster') if toClassName is 'Monster'

    try
      toClass = new (require "../classes/#{newClass}")()
    catch
      toClass = new (require "../classes/Monster")()
      toClassName = "Monster"

    @profession = toClass
    toClass.load @
    @professionName = toClassName

  canEquip: (item) ->
    current = _.findWhere @equipment, {type: item.type}
    current.score() <= item.score() and @level.getValue()*15 >= item.score()

  isBetterItem: (item) ->
    current = _.findWhere @equipment, {type: item.type}
    current.score() < item.score()

  generateBaseEquipment: ->
    @equipment = [
      new Equipment {type: "body",    class: "newbie", name: "Bloody Corpse", con: 30}
      new Equipment {type: "feet",    class: "newbie", name: "Nails of Evil Doom of Evil", dex: 30}
      new Equipment {type: "finger",  class: "newbie", name: "Golden Ring, Fit for Bullying", int: 30}
      new Equipment {type: "hands",   class: "newbie", name: "Fake Infinity Gauntlet Merch", str: 30}
      new Equipment {type: "head",    class: "newbie", name: "Toothy Fangs", wis: 30}
      new Equipment {type: "legs",    class: "newbie", name: "Skull-adorned Legging", agi: 30}
      new Equipment {type: "neck",    class: "newbie", name: "Tribal Necklace", luck: 10}
      new Equipment {type: "mainhand",class: "newbie", name: "Large Bloody Bone", str: 10, dex: 10}
      new Equipment {type: "offhand", class: "newbie", name: "Chunk of Meat", con: 10, agi: 10}
      new Equipment {type: "charm",   class: "newbie", name: "Wooden Human Tooth Replica", int: 10, wis: 10}
    ]

  pullOutStatsFrom: (base) ->
    stats = _.omit base, ["level", "zone", "name", "random", "class", "_id"]
    [stats.type, stats.class, stats.name] = ["monster", "newbie", "monster essence"]
    stats

module.exports = exports = Monster
