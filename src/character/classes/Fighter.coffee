
Class = require "./../base/Class"

class Fighter extends Class

  baseHp: 10
  baseHpPerLevel: 20
  baseHpPerCon: 7

  baseMp: 2
  baseMpPerLevel: 2
  baseMpPerInt: 1

  load: (player) ->
    super player

module.exports = exports = Fighter