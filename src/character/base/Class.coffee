
Personality = require "./Personality"
_ = require "underscore"

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

  ###
    deadVariables contains:
      deadPlayers
      numDead
      deadPlayerTotalXp
      deadPlayerAverageXp
  ###

  combatEndXpGain: (player, deadVariables) ->
    @baseXpGainPerCombat + _.reduce (_.pluck (_.pluck deadVariables.deadPlayers, 'level'), '__current'),
      ((prevVal, level) => prevVal + (level * @baseXpPerOpponentLevel))
    , 0

  eventModifier: (event) ->
    event.min

  load: (player) ->
    player.on 'walk', ->
      player.gainXp 1

module.exports = exports = Class