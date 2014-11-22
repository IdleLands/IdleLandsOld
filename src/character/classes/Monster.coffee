
Class = require "./../base/Class"

`/**
  * This is the default class for all monsters in the game if not specified otherwise. It was added to the game for players
  * for funsies.
  *
  * @name Monster
  * @physical
  * @statPerLevel {str} 4
  * @statPerLevel {dex} 4
  * @statPerLevel {con} 4
  * @statPerLevel {int} 4
  * @statPerLevel {wis} 4
  * @statPerLevel {agi} 4
  * @category Classes
  * @package Player
*/`
class Monster extends Class

  baseHp: 100
  baseHpPerLevel: 4
  baseHpPerCon: 4

  baseMp: 100
  baseMpPerLevel: 4
  baseMpPerInt: 4

  baseConPerLevel: 4
  baseDexPerLevel: 4
  baseAgiPerLevel: 4
  baseStrPerLevel: 4
  baseIntPerLevel: 4
  baseWisPerLevel: 4

  baseXpGainPerCombat: 200
  baseXpGainPerOpponentLevel: 100

  baseXpLossPerCombat: 5
  baseXpLossPerOpponentLevel: 1

  load: (player) ->
    super player

module.exports = exports = Monster
