
_ = require "underscore"
Equipment = require "../item/Equipment"

class BossFactory
  constructor: (@game) ->

  createBoss: (name) ->
    baseObj = BossInformation.bosses[name].stats
    baseObj.name = name
    monster = @game.monsterGenerator.generateMonster baseObj.score, baseObj
    _.each baseObj.items, (item) ->
      baseItem = _.clone BossInformation.items[item]
      baseItem.name = item
      monster.equip new Equipment baseItem

    monster

class BossInformation
  @items =
    "Goblin Lord Shortsword":
      itemClass: "idle"
      type: "mainhand"

  @bosses =
    "Goblin Lord":
      stats:
        'class': 'Monster'
        hp: 3000
        level: 15
        score: 500
      items: [
        "Goblin Lord Shortsword"
      ]

module.exports = exports = BossFactory