
Class = require "./../base/Class"

class Jester extends Class

  baseHp: 30
  baseHpPerLevel: 10
  baseHpPerCon: 12

  baseMp: 0
  baseMpPerLevel: 0
  baseMpPerInt: 0

  baseConPerLevel: 0
  baseDexPerLevel: 0
  baseAgiPerLevel: 0
  baseStrPerLevel: 0
  baseIntPerLevel: 0
  baseWisPerLevel: 0
  baseLuckPerLevel: 3

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

  str: (player, base) -> -base + player.calc.stat 'luck'
  dex: (player, base) -> -base + player.calc.stat 'luck'
  int: (player, base) -> -base + player.calc.stat 'luck'
  con: (player, base) -> -base + player.calc.stat 'luck'
  agi: (player, base) -> -base + player.calc.stat 'luck'
  wis: (player, base) -> -base + player.calc.stat 'luck'
  strPercent: (player, base) -> -base + player.calc.stat 'luckPercent'
  dexPercent: (player, base) -> -base + player.calc.stat 'luckPercent'
  intPercent: (player, base) -> -base + player.calc.stat 'luckPercent'
  conPercent: (player, base) -> -base + player.calc.stat 'luckPercent'
  agiPercent: (player, base) -> -base + player.calc.stat 'luckPercent'
  wisPercent: (player, base) -> -base + player.calc.stat 'luckPercent'

  load: (player) ->
    super player

module.exports = exports = Jester