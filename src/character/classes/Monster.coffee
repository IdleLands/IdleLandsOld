
Class = require "./../base/Class"

class Monster extends Class

  baseHp: 50
  baseHpPerLevel: 4
  baseHpPerCon: 4

  baseMp: 50
  baseMpPerLevel: 4
  baseMpPerInt: 4

  baseConPerLevel: 4
  baseDexPerLevel: 4
  baseAgiPerLevel: 4
  baseStrPerLevel: 4
  baseIntPerLevel: 4
  baseWisPerLevel: 4
  baseLuckPerLevel: 4

  baseXpGainPerCombat: 0
  baseXpGainPerOpponentLevel: 0

  baseXpLossPerCombat: 0
  baseXpLossPerOpponentLevel: 0

  load: (player) ->
    super player

module.exports = exports = Monster