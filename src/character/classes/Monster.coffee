
Class = require "./../base/Class"

class Monster extends Class

  baseHp: 10
  baseHpPerLevel: 5
  baseHpPerCon: 5

  baseMp: 10
  baseMpPerLevel: 5
  baseMpPerInt: 5

  baseConPerLevel: 1
  baseDexPerLevel: 1
  baseAgiPerLevel: 1
  baseStrPerLevel: 1
  baseIntPerLevel: 1
  baseWisPerLevel: 1

  baseXpGainPerCombat: 0
  baseXpGainPerOpponentLevel: 0

  baseXpLossPerCombat: 0
  baseXpLossPerOpponentLevel: 0

  load: (player) ->
    super player

module.exports = exports = Monster