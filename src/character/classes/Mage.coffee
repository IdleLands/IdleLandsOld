
Class = require "./../base/Class"

class Mage extends Class

  baseHp: 5
  baseHpPerLevel: 10
  baseHpPerCon: 3

  baseMp: 10
  baseMpPerLevel: 5
  baseMpPerInt: 10

  load: (player) ->
    super player

module.exports = exports = Mage