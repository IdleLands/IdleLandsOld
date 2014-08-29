
Class = require "./../base/Class"

class Monster extends Class

  baseHp: 50
  baseHpPerLevel: 4
  baseHpPerCon: 4

  baseMp: 50
  baseMpPerLevel: 4
  baseMpPerInt: 4

  baseConPerLevel: 2
  baseDexPerLevel: 2
  baseAgiPerLevel: 2
  baseStrPerLevel: 2
  baseIntPerLevel: 2
  baseWisPerLevel: 2
  baseLuckPerLevel: 2

  baseXpGainPerCombat: 0
  baseXpGainPerOpponentLevel: 0

  baseXpLossPerCombat: 0
  baseXpLossPerOpponentLevel: 0

  load: (player) ->
    super player

module.exports = exports = Monster