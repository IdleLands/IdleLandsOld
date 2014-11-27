
Class = require "./../base/Class"

`/**
  * This class is a healing class. It has some powerful damaging spells, but mostly focuses on helping allies.
  *
  * @name Cleric
  * @magical
  * @support
  * @itemScore int*0.7 + wis*1.5 - str*0.4 - dex*0.4
  * @statPerLevel {str} 2
  * @statPerLevel {dex} 1
  * @statPerLevel {con} 1
  * @statPerLevel {int} 1
  * @statPerLevel {wis} 5
  * @statPerLevel {agi} 1
  * @minDamage 15%
  * @mpregen 5%
  * @category Classes
  * @package Player
*/`
class Cleric extends Class

  baseHp: 40
  baseHpPerLevel: 12
  baseHpPerCon: 5

  baseMp: 150
  baseMpPerLevel: 3
  baseMpPerInt: 2
  baseMpPerWis: 4

  baseConPerLevel: 2
  baseDexPerLevel: 1
  baseAgiPerLevel: 1
  baseStrPerLevel: 2
  baseIntPerLevel: 1
  baseWisPerLevel: 5

  itemScore: (player, item) ->
    item.int*0.7 +
    item.wis*1.5 -
    item.str*0.4 -
    item.dex*0.4

  physicalAttackChance: -> -10

  mpregen: (player) -> Math.floor(player.mp.maximum*0.05)

  minDamage: (player) ->
    player.calc.damage()*0.15

  load: (player) ->
    super player

module.exports = exports = Cleric
