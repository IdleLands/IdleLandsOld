
Class = require "./../base/Class"

class Bard extends Class

  baseHp: 30
  baseHpPerLevel: 10
  baseHpPerCon: 4

  baseMp: 10
  baseMpPerLevel: 3
  baseMpPerInt: 5

  baseConPerLevel: 1
  baseDexPerLevel: 1
  baseAgiPerLevel: 3
  baseStrPerLevel: 1
  baseIntPerLevel: 3
  baseWisPerLevel: 3

  itemScore: (player, item) ->
    item.int*1.4
    + item.wis*1.4
    - item.con*0.8
    - item.str*0.8

  physicalAttackChance: -> -20

  minDamage: (player) ->
    player.calc.damage()*0.10

  load: (player) ->
    super player

module.exports = exports = Bard