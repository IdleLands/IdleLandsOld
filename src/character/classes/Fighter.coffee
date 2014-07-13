
Class = require "./../base/Class"

class Fighter extends Class

  baseHp: 10
  baseHpPerLevel: 20
  baseHpPerCon: 10

  baseMp: 2
  baseMpPerLevel: 3
  baseMpPerInt: 2

  load: (player) ->
    super player

module.exports = exports = Fighter