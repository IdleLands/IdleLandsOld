
Class = require "./../base/Class"

class Mage extends Class

  baseHp: 25
  baseHpPerLevel: 5
  baseHpPerCon: 3

  baseMp: 10
  baseMpPerLevel: 4
  baseMpPerInt: 6

  baseConPerLevel: 1
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

  minDamage: ->
    1

  load: (player) ->
    super player

module.exports = exports = Mage