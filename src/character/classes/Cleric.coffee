
Class = require "./../base/Class"

class Cleric extends Class

  baseHp: 7
  baseHpPerLevel: 12
  baseHpPerCon: 4

  baseMp: 8
  baseMpPerLevel: 3
  baseMpPerInt: 7

  load: (player) ->
    super player

module.exports = exports = Cleric