
_ = require "underscore"
Class = require "./../base/Class"

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
    player.calc.damage()*0.40

  maxBandwidth: (player) ->
    56*Math.floor(Math.pow(player.level.getValue(),2)/100)

  events: {}

  load: (player) ->
    super player
    player.special.maximum = player.profession.maxBandwidth player
    player.special.name = "Bitrate"
    player.on "combat.battle.start", @events.battleStart = ->
      player.special.maximum = player.profession.maxBandwidth player
      player.special.toMaximum()

  unload: (player) ->
    player.special.maximum = 0
    player.special.name = ""
    player.off "combat.battle.start", @events.battleStart

module.exports = exports = Bitomancer