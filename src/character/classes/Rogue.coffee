
Class = require "./../base/Class"

class Rogue extends Class

  baseHp: 30
  baseHpPerLevel: 10
  baseHpPerCon: 6

  baseMp: 0
  baseMpPerLevel: 1
  baseMpPerInt: 1

  baseConPerLevel: 2
  baseDexPerLevel: 4
  baseAgiPerLevel: 4
  baseStrPerLevel: 2
  baseIntPerLevel: 1
  baseWisPerLevel: 0

  itemScore: (player, item) ->
    item.agi*1.4 +
    item.dex*1.4 +
    item.str*0.7 +
    item.con*0.2 -
    item.wis*0.8 -
    item.int*0.8

  minDamage: (player) ->
    player.calc.damage()*0.37

  events: {}

  load: (player) ->
    super player
    player.special.maximum = 100
    player.special.__current = 100
    player.special.name = "Stamina"

    player.on "combat.battle.start", @events.combatStart = -> player.special.toMaximum()

  unload: (player) ->
    player.special.maximum = 0
    player.special.name = ""

    player.off "combat.battle.start", @events.combatStart

module.exports = exports = Rogue