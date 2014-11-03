
Class = require "./../base/Class"
MessageCreator = require "../../system/MessageCreator"

class Bard extends Class

  baseHp: 30
  baseHpPerLevel: 10
  baseHpPerCon: 6

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

  physicalAttackChance: (player) -> if player.party and player.party.players.length > 1 then -20 else 20

  minDamage: (player) ->
    player.calc.damage()*0.10

  events: {}

  load: (player) ->
    super player

    player.on "combat.party.win", @events.partyWin = ->
      return if player.isMonster
      goldBonus = player.calcGoldGain 1000
      player.gainGold goldBonus
      extra =
        player: player.name

      message = "A stunning performance by %player netted #{goldBonus} gold from the audience!"
      message = MessageCreator.doStringReplace message, player, extra
      player.playerManager.game.broadcast MessageCreator.genericMessage message

  unload: (player) ->
    player.off "combat.party.win", @events.partyWin


module.exports = exports = Bard
