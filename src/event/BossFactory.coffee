
_ = require "lodash"
Equipment = require "../item/Equipment"
chance = new (require "chance")()

class BossFactory

  constructor: (@game) ->

  cantDoBossPartyBattle: (partyName) ->

    currentTimer = BossInformation.timers[partyName] or 0
    respawnTimer = BossInformation.parties[partyName].respawn or 3600
    ((new Date) - currentTimer) < respawnTimer * 1000

  createBossPartyNames: (partyName) ->
    BossInformation.parties[partyName].members

  createBoss: (name, isParty = no) ->
    currentTimer = BossInformation.timers[name]

    try
      respawnTimer = BossInformation.bosses[name].respawn or 3600
    catch e
      @game.errorHandler.captureException new Error "INVALID BOSS RESPAWN/NAME: #{name}"

    return if (not isParty) and ((new Date) - currentTimer) < respawnTimer * 1000

    setAllItemClasses = "guardian"

    baseObj = BossInformation.bosses[name]
    statObj = baseObj.stats

    statObj.name = name

    monster = @game.monsterGenerator.experimentalMonsterGeneration statObj, baseObj.score
    monster.bossPartyName = isParty

    _.each baseObj.items, (item) ->
      baseItem = _.clone BossInformation.items[item.name]
      baseItem.name = item.name
      baseItem.itemClass = setAllItemClasses
      monster.equip new Equipment baseItem
    
    monster.equipment[0].fleePercent = -1000;
    monster.equipment[0].hp = monster.equipment[0].hp ? 0
    monster.equipment[0].hp = monster.level.getValue() * 1000

    monster.on "combat.party.lose", (winningParty) =>
      _.each winningParty, (member) =>

        return if member.isMonster

        _.each baseObj.items, (item) =>
          probability = Math.max 0, Math.min 100, item.dropPercent + member.calc.luckBonus()
          return if not (chance.bool likelihood: probability)
          baseItem = _.clone BossInformation.items[item.name]
          baseItem.name = item.name
          baseItem.itemClass = setAllItemClasses

          itemInst = new Equipment baseItem

          @game.equipmentGenerator.addPropertiesToItem itemInst, member.calc.luckBonus()

          event = rangeBoost: 2, remark: "%player looted %item from the corpse of <player.name>#{name}</player.name>."

          if @game.eventHandler.tryToEquipItem event, member, itemInst

            ##TAG:EVENT_EVENT: bossbattle.loot | member, itemName, item | Emitted when a party member loots a boss item
            member.emit "event.bossbattle.loot", member, name, item

        _.each baseObj.collectibles, (item) ->
          probability = Math.max 0, Math.min 100, item.dropPercent + member.calc.luckBonus()
          return if not (chance.bool likelihood: probability)

          baseCollectible =
            name: item.name
            rarity: "guardian"
            description: item.flavorText

          member.handleCollectible baseCollectible

          ##TAG:EVENT_EVENT: bossbattle.lootcollectible | member, bossBaseName, item | Emitted when a party member loots a boss collectible
          member.emit "event.bossbattle.lootcollectible", member, name, item

        ##TAG:EVENT_EVENT: bossbattle.win | member, bossBaseName | Emitted when a party member wins a boss battle
        member.emit "event.bossbattle.win", member, name

      if monster.bossPartyName
        BossInformation.timers[monster.bossPartyName] = new Date()
      else
        BossInformation.timers[name] = new Date()

    monster.on "combat.party.win", (losingParty) ->

      _.each losingParty, (member) ->
        ##TAG:EVENT_EVENT: bossbattle.lose | member, bossBaseName | Emitted when a party member loses a boss battle
        member.emit "event.bossbattle.lose", member, name

        member.handleTeleport tile: object: properties: toLoc: baseObj.teleportOnDeath, movementType: "teleport" if baseObj.teleportOnDeath

    monster

class BossInformation
  @timers = {}
  @parties = require "../../config/bossparties.json"
  @items = _.extend (require "../../config/bossitems.json"), (require "../../config/treasure.json")
  @bosses = require "../../config/boss.json"

module.exports = exports = BossFactory
