
Class = require "./../base/Class"

class Cleric extends Class

  baseHp: 40
  baseHpPerLevel: 12
  baseHpPerCon: 3

  baseMp: 8
  baseMpPerLevel: 3
  baseMpPerInt: 2

  baseConPerLevel: 2
  baseDexPerLevel: 1
  baseAgiPerLevel: 1
  baseStrPerLevel: 2
  baseIntPerLevel: 1
  baseWisPerLevel: 5

  itemScore: (player, item) ->
    item.wis*1.5
    - item.str*0.2
    - item.dex*0.1
    - item.int*0.1

  physicalAttackChance: -> -10

  minDamage: (player) ->
    player.calc.damage()*0.15

  load: (player) ->
    super player

module.exports = exports = Cleric