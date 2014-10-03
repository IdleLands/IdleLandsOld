
Class = require "./../base/Class"

class SandwichArtist extends Class

  baseHp: 40
  baseHpPerLevel: 12
  baseHpPerCon: 5

  baseMp: 10
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