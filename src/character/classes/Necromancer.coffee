
Class = require "./../base/Class"

`/**
  * This class is a summoning class that focuses on debuffing its foes so its minions can take them down.
  *
  * @name Necromancer
  * @special Minions (The Necromancer gets +1 minion every 25 levels.)
  * @magical
  * @dps
  * @hp 10+[level*3]+[con*3]
  * @mp 300+[level*10]+[int*4]+[wis*15]
  * @itemScore int*0.1 + wis*2 + str*0.7 + dex*0.7 - agi*0.8 - con*0.5
  * @statPerLevel {str} 3
  * @statPerLevel {dex} 3
  * @statPerLevel {con} 0
  * @statPerLevel {int} 1
  * @statPerLevel {wis} 7
  * @statPerLevel {agi} -2
  * @statPerLevel {luck} -1
  * @minDamage 15%
  * @mpregen 5%
  * @category Classes
  * @package Player
*/`
class Necromancer extends Class

  baseHp: 10
  baseHpPerLevel: 3
  baseHpPerCon: 3

  baseMp: 300
  baseMpPerLevel: 10
  baseMpPerInt: 4
  baseMpPerWis: 15

  baseConPerLevel: 0
  baseDexPerLevel: 3
  baseAgiPerLevel: -2
  baseStrPerLevel: 3
  baseIntPerLevel: 1
  baseWisPerLevel: 7
  baseLuckPerLevel: -1

  itemScore: (player, item) ->
    item.wis*2 +
    item.int*0.1 +
    item.dex*0.7 +
    item.str*0.7 -
    item.agi*0.8 -
    item.con*0.5

  physicalAttackChance: -> -15

  prone: -> 1
  venom: -> 1
  poison: -> 1
  startle: -> 1
  hpPercent: -> -15
  agiPercent: -> -10

  mpregen: (player) -> Math.floor(player.mp.maximum*0.05)

  minDamage: (player) ->
    player.calc.damage()*0.05

  numSummons: (player) ->
    Math.ceil player.level.getValue() / 25

  events: {}

  load: (player) ->
    super player
    player.special.name = "Minions"
    player.on "combat.battle.start", @events.battleStart = =>
      player.special.maximum = @numSummons player
      player.special.toMinimum()

  unload: (player) ->
    player.special.maximum = 0
    player.special.name = ""
    player.off "combat.battle.start", @events.battleStart

module.exports = exports = Necromancer
