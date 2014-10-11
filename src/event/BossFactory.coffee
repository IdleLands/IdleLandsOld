
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
          member.emit "event.bossbattle.loot", member, name, item

        member.emit "event.bossbattle.win", member, name

      BossInformation.timers[name] = new Date()

    monster.on "combat.party.win", (losingParty) ->
      baseObj.playerLose? forPlayer, losingParty

      _.each losingParty, (member) ->
        member.emit "event.bossbattle.lose", member, name

    monster

class BossInformation
  @timers = {}
  @items =
    "Goblin Lord Shortsword":
      type: "mainhand"
      str: 100
      agi: 100
      dex: 100
      hp: 500
      silver: 1
    "Mummy Lord Greatsword":
      type: "mainhand"
      str: 200
      agi: 200
      dex: 200
      hp: 700
      prone: 1
      offense: 3
    "Lizard King Staff":
      type: "mainhand"
      int: 500
      wis: 500
      agi: 200
      con: 200

  @bosses =
    "Goblin Lord":
      respawn: 7200
      availableScore: 500
      stats:
        'class': 'Monster'
        hp: 15000
        level: 15
        agi: 1500
        dex: 1000
        str: 1500
      items: [
        { name: "Goblin Lord Shortsword", dropPercent: 35 }
      ]

    "Mummy Lord":
      respawn: 7200
      availableScore: 1500
      stats:
        'class': 'Fighter'
        hp: 25000
        level: 25
        agi: 1500
        dex: 1000
        str: 2500
      items: [
        { name: "Mummy Lord Greatsword", dropPercent: 35 }
      ]

    "Lizard King":
      respawn: 10800
      availableScore: 2500
      stats:
        'class': 'Mage'
        hp: 30000
        level: 35
        agi: 1500
        dex: 1000
        mp: 10000
        str: 3500
        int: 2500
      items: [
        { name: "Lizard King Staff", dropPercent: 35 }
      ]

module.exports = exports = BossFactory
