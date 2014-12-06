
_ = require "underscore"
Class = require "./../base/Class"

`/**
  * This class is a debuffing magical class. It uses Bitrate to stun and destroy its foes.
  *
  * @name Bitomancer
  * @special Bitrate (The Bitomancer gets a certain Bitrate with which to virtually assault their opponents.)
  * @magical
  * @dps
  * @hp 70+[level*12]+[con*7]
  * @mp 70+[level*3]+[int*3]
  * @itemScore int*1.4 + dex*0.8 + agi*0.8 - con*0.9 - str*0.9
  * @statPerLevel {str} 1
  * @statPerLevel {dex} 3
  * @statPerLevel {con} 1
  * @statPerLevel {int} 4
  * @statPerLevel {wis} 3
  * @statPerLevel {agi} 1
  * @minDamage 30%
  * @category Classes
  * @package Player
*/`
class Bitomancer extends Class

  baseHp: 70
  baseHpPerLevel: 12
  baseHpPerCon: 7

  baseMp: 70
  baseMpPerLevel: 3
  baseMpPerInt: 3

  baseConPerLevel: 1
  baseDexPerLevel: 3
  baseAgiPerLevel: 1
  baseStrPerLevel: 1
  baseIntPerLevel: 4
  baseWisPerLevel: 3

  itemScore: (player, item) ->
    item.int*1.4 +
    item.dex*0.8 +
    item.agi*0.8 -
    item.con*0.9 -
    item.str*0.9

  physicalAttackChance: (player) -> -15

  minDamage: (player) ->
    player.calc.damage()*0.30

  maxBandwidth: (player) ->
    56*Math.floor(Math.pow(player.level.getValue(),2)/100)

  events: {}

  load: (player) ->
    super player
    player.special.maximum = @maxBandwidth player
    player.special.name = "Bitrate"
    player.on "combat.battle.start", @events.battleStart = =>
      return if player.professionName isnt "Bitomancer"
      player.special.maximum = @maxBandwidth player
      player.special.toMaximum()

  unload: (player) ->
    player.special.maximum = 0
    player.special.name = ""
    player.off "combat.battle.start", @events.battleStart

module.exports = exports = Bitomancer