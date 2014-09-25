
Class = require "./../base/Class"

class Generalist extends Class

  baseHp: 50
  baseHpPerLevel: 15
  baseHpPerCon: 6

  baseMp: 5
  baseMpPerLevel: 2
  baseMpPerInt: 2

  baseConPerLevel: 2
  baseDexPerLevel: 2
  baseAgiPerLevel: 2
  baseStrPerLevel: 2
  baseIntPerLevel: 2
  baseWisPerLevel: 2

  baseXpGainPerCombat: 120
  baseXpGainPerOpponentLevel: 60

  baseXpLossPerCombat: 8
  baseXpLossPerOpponentLevel: 3

  minDamage: (player) ->
    player.calc.damage()*0.35

  load: (player) ->
    super player

module.exports = exports = Generalist