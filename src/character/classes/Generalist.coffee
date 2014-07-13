
Class = require "./../base/Class"

class Generalist extends Class

  baseHp: 10
  baseHpPerLevel: 15
  baseHpPerCon: 4

  baseMp: 5
  baseMpPerLevel: 2
  baseMpPerInt: 2

  baseXpGainPerCombat: 120
  baseXpGainPerOpponentLevel: 60

  baseXpLossPerCombat: 8
  baseXpLossPerOpponentLevel: 3

  load: (player) ->
    super player

module.exports = exports = Generalist