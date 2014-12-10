
Class = require "./../base/Class"
_ = require "lodash"
MessageCreator = require "../../system/MessageCreator"

`/**
  * The Archer is a physical debuff/dps class. Their Focus stat increases critical chance by up to 50%,
  * and allows access to powerful skills. Focus increases every turn and with use of the Take Aim skill,
  * and decreases when the Archer is damaged as well as when it is spent.
  *
  * @name Archer
  * @physical
  * @dps
  * @hp 70+[level*10]+[con*6]
  * @mp 30+[level*2]+[int*1]
  * @special Focus (The Archer builds focus over time, resulting in devastating attacks if unchecked.)
  * @itemScore agi*1.2 + dex*1.6 + str*0.3 - int
  * @statPerLevel {str} 2
  * @statPerLevel {dex} 4
  * @statPerLevel {con} 2
  * @statPerLevel {int} 1
  * @statPerLevel {wis} 1
  * @statPerLevel {agi} 3
  * @minDamage 50%
  * @category Classes
  * @package Player
*/`
class Archer extends Class

  baseHp: 70
  baseHpPerLevel: 10
  baseHpPerCon: 6

  baseMp: 30
  baseMpPerLevel: 2
  baseMpPerInt: 1

  baseConPerLevel: 2
  baseDexPerLevel: 4
  baseAgiPerLevel: 3
  baseStrPerLevel: 2
  baseIntPerLevel: 1
  baseWisPerLevel: 1

  itemScore: (player, item) ->
    item.agi*1.2 +
    item.dex*1.6 +
    item.str*0.3 -
    item.int

  physicalAttackChance: -> -10

  criticalChance: (player) -> 50*player.special.getValue()

  minDamage: (player) ->
    player.calc.damage()*0.5

  events: {}

  load: (player) ->
    super player
    player.special.maximum = 100
    player.special.__current = 0
    player.special.name = "Focus"

    player.on "combat.battle.start", @events.combatStart = -> player.special.toMinimum()
    player.on "combat.round.start", @events.roundStart = -> player.special.add 10
    player.on "combat.self.damaged", @events.hitReceived = -> player.special.sub 7
    player.on "combat.ally.flee", @events.allyFled = (fledPlayer) ->
      return if not fledPlayer.fled
      fledPlayer.fled = false
      message = "%casterName dragged %targetName back into combat with a grappling hook arrow!"
      extra =
        targetName: fledPlayer.name
        casterName: player.name
      newMessage = MessageCreator.doStringReplace message, player, extra
      player.playerManager.game.currentBattle?.broadcast newMessage

  unload: (player) ->
    player.special.maximum = 0
    player.special.name = ""

    player.off "combat.battle.start", @events.combatStart
    player.off "combat.round.start", @events.roundStart
    player.off "combat.self.damaged", @events.hitReceived

module.exports = exports = Archer
