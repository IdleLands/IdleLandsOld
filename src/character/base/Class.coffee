
Personality = require "./Personality"
_ = require "underscore"

class Class extends Personality

  baseHp: 10
  baseHpPerLevel: 15
  baseHpPerCon: 5

  baseMp: 5
  baseMpPerLevel: 2
  baseMpPerInt: 3

  battleXpGainPercent: 10

  baseXpGainPerCombat: 100
  baseXpGainPerOpponentLevel: 50

  baseXpLossPerCombat: 10
  baseXpLossPerOpponentLevel: 5

  baseConPerLevel: 0
  baseDexPerLevel: 0
  baseAgiPerLevel: 0
  baseStrPerLevel: 0
  baseIntPerLevel: 0
  baseWisPerLevel: 0
  baseLuckPerLevel: 0

  hp: (player) ->
    @baseHp + (@baseHpPerLevel*player.level.getValue()) + (@baseHpPerCon*player.calc.stat 'con')

  mp: (player) ->
    @baseMp + (@baseMpPerLevel*player.level.getValue()) + (@baseMpPerInt*player.calc.stat 'int')

  con: (player) ->
    @baseConPerLevel*player.level.getValue()

  dex: (player) ->
    @baseDexPerLevel*player.level.getValue()

  agi: (player) ->
    @baseAgiPerLevel*player.level.getValue()

  str: (player) ->
    @baseStrPerLevel*player.level.getValue()

  int: (player) ->
    @baseIntPerLevel*player.level.getValue()

  wis: (player) ->
    @baseWisPerLevel*player.level.getValue()

  luck: (player) ->
    @baseLuckPerLevel*player.level.getValue()

  ###
    deadVariables contains:
      deadPlayers
      numDead
      deadPlayerTotalXp
      deadPlayerAverageXp
  ###

  combatEndXpGain: (player, deadVariables) ->
    @baseXpGainPerCombat + _.reduce (_.pluck (_.pluck deadVariables.deadPlayers, 'level'), '__current'),
      ((prevVal, level) => prevVal + (level * @baseXpGainPerOpponentLevel))
    , 0

  combatEndXpLoss: (player, deadVariables) ->
    @baseXpLossPerCombat + _.reduce (_.pluck (_.pluck deadVariables.winningParty.players, 'level'), '__current'),
      ((prevVal, level) => prevVal + (level * @baseXpLossPerOpponentLevel))
    , 0

  eventModifier: (event) ->
    event.min

  load: (player) ->
    player.on 'walk', ->
      player.gainXp 10

module.exports = exports = Class
