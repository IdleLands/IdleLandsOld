
Class = require "./../base/Class"
MessageCreator = require "../../system/MessageCreator"

###*
  * This class is a very supportive class. They sing their songs to buff their allies.
  * If they have no allies, they are more likely to be an offensive force.
  *
  * @name Bard
  * @magical
  * @support
  * @itemScore int*1.4 + wis*1.4 - con*0.8 - str*0.8
  * @statPerLevel {str} 1
  * @statPerLevel {dex} 1
  * @statPerLevel {con} 1
  * @statPerLevel {int} 3
  * @statPerLevel {wis} 3
  * @statPerLevel {agi} 3
  * @minDamage 10%
  * @category Classes
  * @package Player
###
class Bard extends Class

  baseHp: 50
  baseHpPerLevel: 10
  baseHpPerCon: 6

  baseMp: 100
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
