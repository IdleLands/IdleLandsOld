
Class = require "./../base/Class"
MessageCreator = require "../../system/MessageCreator"

class Bard extends Class

  baseHp: 30
  baseHpPerLevel: 10
  baseHpPerCon: 4

  baseMp: 10
  baseMpPerLevel: 3
  baseMpPerInt: 5

  baseConPerLevel: 1
  baseDexPerLevel: 1
  baseAgiPerLevel: 3
  baseStrPerLevel: 1
  baseIntPerLevel: 3
  baseWisPerLevel: 3

  itemScore: (player, item) ->
    item.int*1.4 +
    item.wis*1.4 -
    item.con*0.8 -
    item.str*0.8

  physicalAttackChance: -> -20

  minDamage: (player) ->
    player.calc.damage()*0.10

  events: {}

  load: (player) ->
    super player

    player.on "combat.party.win", @events.partyWin = ->
      goldBonus = player.calcGoldGain 1000
      player.gainGold goldBonus
      player.playerManager.game.broadcast MessageCreator.genericMessage "A stunning performance by #{player.name} netted #{goldBonus} gold from the audience!"

  unload: (player) ->
    player.off "combat.party.win", @events.partyWin


module.exports = exports = Bard