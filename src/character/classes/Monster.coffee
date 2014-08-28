
Class = require "./../base/Class"

class Monster extends Class

  baseHp: 50
  baseHpPerLevel: 15
  baseHpPerCon: 15

  baseMp: 50
  baseMpPerLevel: 15
  baseMpPerInt: 15

  baseConPerLevel: 10
  baseDexPerLevel: 10
  baseAgiPerLevel: 10
  baseStrPerLevel: 10
  baseIntPerLevel: 10
  baseWisPerLevel: 10

  baseXpGainPerCombat: 0
  baseXpGainPerOpponentLevel: 0

  baseXpLossPerCombat: 0
  baseXpLossPerOpponentLevel: 0

  load: (player) ->
    super player

module.exports = exports = Monster