
Class = require "./../base/Class"

###*
  * This class is an offensive magical class. They use their numerous fireballs to burn their opponents into submission.
  *
  * @name Mage
  * @magical
  * @dps
  * @itemScore int*1.4 + con*0.4 - str*0.8 - dex*0.3
  * @statPerLevel {str} 1
  * @statPerLevel {dex} 1
  * @statPerLevel {con} 2
  * @statPerLevel {int} 5
  * @statPerLevel {wis} 2
  * @statPerLevel {agi} 2
  * @mpregen 5%
  * @category Classes
  * @package Player
###
class Mage extends Class

  baseHp: 25
  baseHpPerLevel: 5
  baseHpPerCon: 4

  baseMp: 200
  baseMpPerLevel: 4
  baseMpPerInt: 6

  baseConPerLevel: 2
  baseDexPerLevel: 1
  baseAgiPerLevel: 2
  baseStrPerLevel: 1
  baseIntPerLevel: 5
  baseWisPerLevel: 2

  itemScore: (player, item) ->
    item.int*1.4 +
    item.con*0.4 -
    item.str*0.8 -
    item.dex*0.3

  physicalAttackChance: -> -25

  mpregen: (player) -> Math.floor(player.mp.maximum*0.05)

  minDamage: ->
    1

  load: (player) ->
    super player

module.exports = exports = Mage