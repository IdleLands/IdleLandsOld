
Class = require "./../base/Class"

class Monster extends Class

  baseHp: 50
  baseHpPerLevel: 8
  baseHpPerCon: 8

  baseMp: 50
  baseMpPerLevel: 8
  baseMpPerInt: 8

  baseConPerLevel: 5
  baseDexPerLevel: 5
  baseAgiPerLevel: 5
  baseStrPerLevel: 5
  baseIntPerLevel: 5
  baseWisPerLevel: 5

  baseXpGainPerCombat: 0
  baseXpGainPerOpponentLevel: 0

  baseXpLossPerCombat: 0
  baseXpLossPerOpponentLevel: 0

  load: (player) ->
    super player

module.exports = exports = Monster