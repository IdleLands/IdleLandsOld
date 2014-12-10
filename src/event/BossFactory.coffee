
_ = require "lodash"
Equipment = require "../item/Equipment"
chance = new (require "chance")()

class BossFactory
  constructor: (@game) ->

  createBoss: (name, forPlayer) ->
    currentTimer = BossInformation.timers[name]

    try
      respawnTimer = BossInformation.bosses[name].respawn or 3600
    catch e
      console.log "INVALID BOSS RESPAWN/NAME: #{name}"

    return if ((new Date) - currentTimer) < respawnTimer * 1000

    setAllItemClasses = "guardian"

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
          probability = Math.max 0, Math.min 100, item.dropPercent + member.calc.luckBonus()
          return if not (chance.bool likelihood: probability)
          baseItem = _.clone BossInformation.items[item.name]
          baseItem.name = item.name
          baseItem.itemClass = setAllItemClasses

          itemInst = new Equipment baseItem

          event = rangeBoost: 2, remark: "%player looted %item from the corpse of <player.name>#{name}</player.name>."

          if @game.eventHandler.tryToEquipItem event, member, itemInst
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
  @items = require "../../config/bossitems.json"
  @bosses = require "../../config/boss.json"

module.exports = exports = BossFactory
