
Class = require "./../base/Class"

`/**
  * This class makes lunch for its allies and foes alike. It is a true savior, but watch out for the poison.
  *
  * @name SandwichArtist
  * @physical
  * @medic
  * @support
  * @itemScore dex*2 + str*0.8 - int*0.5
  * @statPerLevel {str} 3
  * @statPerLevel {dex} 5
  * @statPerLevel {con} 1
  * @statPerLevel {int} 1
  * @statPerLevel {wis} 1
  * @statPerLevel {agi} 1
  * @minDamage 15%
  * @category Classes
  * @package Player
*/`
class SandwichArtist extends Class

  baseHp: 40
  baseHpPerLevel: 12
  baseHpPerCon: 5

  baseMp: 100
  baseMpPerLevel: 3
  baseMpPerInt: 5

  baseConPerLevel: 1
  baseDexPerLevel: 5
  baseAgiPerLevel: 1
  baseStrPerLevel: 3
  baseIntPerLevel: 1
  baseWisPerLevel: 1

  itemScore: (player, item) ->
    item.dex*2 +
    item.str*0.8 -
    item.int*0.5

  physicalAttackChance: -> -10

  minDamage: (player) ->
    player.calc.damage()*0.15

  events: {}

  load: (player) ->
    super player

module.exports = exports = SandwichArtist