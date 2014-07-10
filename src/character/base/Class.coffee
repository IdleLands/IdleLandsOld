
###
  if nameless lands classes are implemented, make higher tier classes descendants of a base class
###

Personality = require "./Personality"

class Class extends Personality

  battleXpGainPercent: 10

  baseHp: 10
  baseHpPerLevel: 15
  baseHpPerCon: 5

  baseMp: 0
  baseMpPerLevel: 0
  baseMpPerInt: 0

  baseXpGainPerCombat: 100
  baseXpPerOpponentLevel: 50

  hp: (player) ->
    @baseHp + (@baseHpPerLevel*player.level.getValue()) + (@baseHpPerCon*player.calc.stat 'con')

  mp: (player) ->
    @baseMp + (@baseMpPerLevel*player.level.getValue()) + (@baseMpPerInt*player.calc.stat 'int')

  combatEndXpGain: (player, party) ->
    @baseXpGainPerCombat + _.reduce (_.pluck party, 'level'), ((prevVal, level) => prevVal + (level * @baseXpPerOpponentLevel)), 0

  load: (player) ->
    player.on 'walk', ->
      player.gainXp 1

module.exports = exports = Class