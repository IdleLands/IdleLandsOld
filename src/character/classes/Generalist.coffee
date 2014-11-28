
Class = require "./../base/Class"

`/**
  * This class does a little bit of everything. They have an attack skill that attacks all opponents, a defensive skill, and a healing skill.
  *
  * @name Generalist
  * @physical
  * @support
  * @hp 50+[level*15]+[con*6]
  * @mp 50+[level*2]+[int*2]
  * @statPerLevel {str} 2
  * @statPerLevel {dex} 2
  * @statPerLevel {con} 2
  * @statPerLevel {int} 2
  * @statPerLevel {wis} 2
  * @statPerLevel {agi} 2
  * @minDamage 35%
  * @category Classes
  * @package Player
*/`
class Generalist extends Class

  baseHp: 50
  baseHpPerLevel: 15
  baseHpPerCon: 6

  baseMp: 50
  baseMpPerLevel: 2
  baseMpPerInt: 2

  baseConPerLevel: 2
  baseDexPerLevel: 2
  baseAgiPerLevel: 2
  baseStrPerLevel: 2
  baseIntPerLevel: 2
  baseWisPerLevel: 2

  baseXpGainPerCombat: 120
  baseXpGainPerOpponentLevel: 60

  baseXpLossPerCombat: 8
  baseXpLossPerOpponentLevel: 3

  minDamage: (player) ->
    player.calc.damage()*0.35

  load: (player) ->
    super player

module.exports = exports = Generalist