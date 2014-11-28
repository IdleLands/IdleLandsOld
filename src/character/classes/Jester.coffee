
Class = require "./../base/Class"

`/**
  * This class is a very lucky class. It uses its luck to affect everything. It also gets a bonus to having all events happen more often.
  *
  * @name Jester
  * @physical
  * @hp 30+[level*10]+[con*9]
  * @mp 0
  * @itemScore luck*5 + luckPercent*5 (Note, all other stats are ignored except for special stats like offense, defense, etc)
  * @statPerLevel {str} 0
  * @statPerLevel {dex} 0
  * @statPerLevel {con} 0
  * @statPerLevel {int} 0
  * @statPerLevel {wis} 0
  * @statPerLevel {agi} 0
  * @statPerLevel {luck} 4
  * @category Classes
  * @package Player
*/`
class Jester extends Class

  baseHp: 30
  baseHpPerLevel: 10
  baseHpPerCon: 9

  baseMp: 0
  baseMpPerLevel: 0
  baseMpPerInt: 0

  baseConPerLevel: 0
  baseDexPerLevel: 0
  baseAgiPerLevel: 0
  baseStrPerLevel: 0
  baseIntPerLevel: 0
  baseWisPerLevel: 0
  baseLuckPerLevel: 4

  itemScore: (player, item) ->
    item.luck*5 +
    item.luckPercent*5 -
    item.agi -
    item.agiPercent -
    item.dex -
    item.dexPercent -
    item.str -
    item.strPercent -
    item.con -
    item.conPercent -
    item.wis -
    item.wisPercent -
    item.int -
    item.intPercent -
    item.xp -
    item.xpPercent -
    item.gold -
    item.goldPercent -
    item.hp -
    item.hpPercent -
    item.mp -
    item.mpPercent -
    item.ice -
    item.icePercent -
    item.fire -
    item.firePercent -
    item.water -
    item.waterPercent -
    item.earth -
    item.earthPercent -
    item.thunder -
    item.thunderPercent

  str: (player) -> player.calc.stat 'luck'
  dex: (player) -> player.calc.stat 'luck'
  int: (player) -> player.calc.stat 'luck'
  con: (player) -> player.calc.stat 'luck'
  agi: (player) -> player.calc.stat 'luck'
  wis: (player) -> player.calc.stat 'luck'
  strPercent: (player) -> player.calc.stat 'luckPercent'
  dexPercent: (player) -> player.calc.stat 'luckPercent'
  intPercent: (player) -> player.calc.stat 'luckPercent'
  conPercent: (player) -> player.calc.stat 'luckPercent'
  agiPercent: (player) -> player.calc.stat 'luckPercent'
  wisPercent: (player) -> player.calc.stat 'luckPercent'

  eventMod: (player) -> player.level.getValue()
  
  fleePercent: (player) -> if (player.hasPersonality 'Drunk' and player.hasPersonality 'Brave') then 230 else if (player.hasPersonality 'Drunk' or player.hasPersonality 'Brave') then 130 else 30

  load: (player) ->
    super player

module.exports = exports = Jester
