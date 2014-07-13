
Class = require "./../base/Class"

class Mage extends Class

  baseHp: 5
  baseHpPerLevel: 5
  baseHpPerCon: 3

  baseMp: 10
  baseMpPerLevel: 4
  baseMpPerInt: 6

  physicalAttackChance: -> -25

  load: (player) ->
    super player

module.exports = exports = Mage