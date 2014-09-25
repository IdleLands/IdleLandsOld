
Class = require "./../base/Class"

class Jester extends Class

  baseHp: 30
  baseHpPerLevel: 10
  baseHpPerCon: 9

  baseMp: 0
  baseMpPerLevel: 0
  baseMpPerInt: 0

  baseConPerLevel: 0
  baseDexPerLevel: 0
  baseAgiPerLevel: 0
  baseStrPerLevel: 0
  baseIntPerLevel: 0
  baseWisPerLevel: 0
  baseLuckPerLevel: 1

  itemScore: (player, item) ->
    item.luck*5 +
    item.luckPercent*5 -
    item.agi -
    item.agiPercent -
    item.dex -
    item.dexPercent -
    item.str -
    item.strPercent -
    item.con -
    item.conPercent -
    item.wis -
    item.wisPercent -
    item.int -
    item.intPercent

  str: (player) -> player.calc.stat 'luck'
  dex: (player) -> player.calc.stat 'luck'
  int: (player) -> player.calc.stat 'luck'
  con: (player) -> player.calc.stat 'luck'
  agi: (player) -> player.calc.stat 'luck'
  wis: (player) -> player.calc.stat 'luck'
  strPercent: (player) -> player.calc.stat 'luckPercent'
  dexPercent: (player) -> player.calc.stat 'luckPercent'
  intPercent: (player) -> player.calc.stat 'luckPercent'
  conPercent: (player) -> player.calc.stat 'luckPercent'
  agiPercent: (player) -> player.calc.stat 'luckPercent'
  wisPercent: (player) -> player.calc.stat 'luckPercent'

  load: (player) ->
    super player

module.exports = exports = Jester
