
_ = require "underscore"
Equipment = require "../item/Equipment"
chance = new (require "chance")()

class BossFactory
  constructor: (@game) ->

  createBoss: (name, forPlayer) ->
    currentTimer = BossInformation.timers[name]
    respawnTimer = BossInformation.bosses[name].respawn or 3600

    return if ((new Date) - currentTimer) < respawnTimer * 1000

    setAllItemClasses = "idle"

    baseObj = BossInformation.bosses[name]
    statObj = baseObj.stats
    statObj.name = name
    monster = @game.monsterGenerator.generateMonster baseObj.score, statObj
    _.each baseObj.items, (item) ->
      baseItem = _.clone BossInformation.items[item.name]
      baseItem.name = item.name
      baseItem.itemClass = setAllItemClasses
      monster.equip new Equipment baseItem

    monster.on "combat.party.lose", (winningParty) =>
      _.each winningParty, (member) =>
        _.each baseObj.items, (item) =>
          return if not (chance.bool likelihood: item.dropPercent)
          baseItem = _.clone BossInformation.items[item.name]
          baseItem.name = item.name
          baseItem.itemClass = setAllItemClasses
          message = "%player looted %item from the corpse of <player.name>#{name}</player.name>."
          @game.eventHandler.doItemEquip member, (new Equipment baseItem), message

      BossInformation.timers[name] = new Date()

    monster.on "combat.party.win", (losingParty) =>
      baseObj.playerLose? forPlayer, losingParty

    monster

class BossInformation
  @timers = {}
  @items =
    "Goblin Lord Shortsword":
      type: "mainhand"
      str: 200
      agi: 200
      dex: 200
      hp: 1000
      silver: 1
    "Mummy Lord Greatsword":
      type: "mainhand"
      str: 400
      agi: 400
      dex: 400
      hp: 2000
      prone: 1
      offense: 3
    "Lizard King Staff":
      int: 500
      wis: 500
      agi: 200
      con: 200

  @bosses =
    "Goblin Lord":
      respawn: 1800
      availableScore: 500
      stats:
        'class': 'Monster'
        hp: 6000
        level: 15
      items: [
        { name: "Goblin Lord Shortsword", dropPercent: 35 }
      ]

    "Mummy Lord":
      respawn: 1800
      availableScore: 1500
      stats:
        'class': 'Fighter'
        hp: 9000
        level: 25
      items: [
        { name: "Mummy Lord Greatsword", dropPercent: 35 }
      ]

    "Lizard King":
      respawn: 1800
      availableScore: 2500
      stats:
        'class': 'Mage'
        hp: 13000
        level: 35
      items: [
        { name: "Lizard King Staff", dropPercent: 35 }
      ]

module.exports = exports = BossFactory