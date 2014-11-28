
Class = require "./../base/Class"

`/**
  * This class is a damaging class. It can use skills to stun or attack multiple times.
  *
  * @name Fighter
  * @physical
  * @tank
  * @hp 120+[level*20]+[con*8]
  * @mp 2+[level*2]+[int*1]
  * @itemScore str*1.1 + con*0.8 + dex*0.3 - agi*0.2 - wis*0.8
  * @statPerLevel {str} 3
  * @statPerLevel {dex} 2
  * @statPerLevel {con} 3
  * @statPerLevel {int} 2
  * @statPerLevel {wis} 1
  * @statPerLevel {agi} 2
  * @minDamage 50%
  * @hpregen 5%
  * @category Classes
  * @package Player
*/`
class Fighter extends Class

  baseHp: 120
  baseHpPerLevel: 20
  baseHpPerCon: 8

  baseMp: 2
  baseMpPerLevel: 2
  baseMpPerInt: 1

  baseConPerLevel: 3
  baseDexPerLevel: 2
  baseAgiPerLevel: 2
  baseStrPerLevel: 3
  baseIntPerLevel: 2
  baseWisPerLevel: 1

  itemScore: (player, item) ->
    item.str*1.1 +
    item.con*0.8 +
    item.dex*0.3 -
    item.agi*0.2 -
    item.wis*0.8

  hpregen: (player) -> Math.floor(player.hp.maximum*0.05)

  minDamage: (player) ->
    player.calc.damage()*0.50

  load: (player) ->
    super player

module.exports = exports = Fighter