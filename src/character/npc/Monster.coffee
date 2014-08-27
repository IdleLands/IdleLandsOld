
Character = require "../base/Character"
Equipment = require "../../item/Equipment"
_ = require "underscore"

class Monster extends Character

  constructor: (options) ->
    baseStatItem = @pullOutStatsFrom options
    level = options.level
    super options

    @level.set level
    @generateBaseEquipment()
    @equipment.push new Equipment baseStatItem

  generateBaseEquipment: ->
    @equipment = [
      new Equipment {type: "body",    class: "newbie", name: "Bloody Corpse", con: 1}
      new Equipment {type: "feet",    class: "newbie", name: "Nails of Evil Doom of Evil", dex: 1}
      new Equipment {type: "finger",  class: "newbie", name: "Golden Ring, Fit for Bullying", int: 1}
      new Equipment {type: "hands",   class: "newbie", name: "Fake Infinity Gauntlet Merch", str: 1}
      new Equipment {type: "head",    class: "newbie", name: "Toothy Fangs", wis: 1}
      new Equipment {type: "legs",    class: "newbie", name: "Skull-adorned Legging", agi: 1}
      new Equipment {type: "neck",    class: "newbie", name: "Tribal Necklace", wis: 1, int: 1}
      new Equipment {type: "mainhand",class: "newbie", name: "Large Bloody Bone", str: 1, luck: 1}
      new Equipment {type: "offhand", class: "newbie", name: "Chunk of Meat", dex: 1, str: 1}
      new Equipment {type: "charm",   class: "newbie", name: "Wooden Human Tooth Replica", con: 1, dex: 1}
    ]

  pullOutStatsFrom: (base) ->
    stats = _.without base, ["level", "zone", "name", "random", "class", "_id"]
    [stats.type, stats.class, stats.name] = ["monster", "newbie", "monster essence"]
    stats

module.exports = exports = Monster