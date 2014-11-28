
Class = require "./../base/Class"

`/**
  * This is one of the default classes for all monsters in the game if not specified otherwise. It was added to the game for players
  * for funsies.
  *
  * @name MagicalMonster
  * @magical
  * @hp 50+[level*2]+[con*2]
  * @mp 50+[level*2]+[int*2]
  * @statPerLevel {str} 2
  * @statPerLevel {dex} 2
  * @statPerLevel {con} 2
  * @statPerLevel {int} 2
  * @statPerLevel {wis} 2
  * @statPerLevel {agi} 2
  * @category Classes
  * @package Player
*/`
class MagicalMonster extends Class

  baseHp: 50
  baseHpPerLevel: 2
  baseHpPerCon: 2

  baseMp: 50
  baseMpPerLevel: 2
  baseMpPerInt: 2

  baseConPerLevel: 2
  baseDexPerLevel: 2
  baseAgiPerLevel: 2
  baseStrPerLevel: 2
  baseIntPerLevel: 2
  baseWisPerLevel: 2

  baseXpGainPerCombat: 400
  baseXpGainPerOpponentLevel: 200

  baseXpLossPerCombat: 50
  baseXpLossPerOpponentLevel: 20

  load: (player) ->
    super player

module.exports = exports = MagicalMonster
