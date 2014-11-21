
Class = require "./../base/Class"
RestrictedNumber = require "restricted-number"

###*
  * This class is very rambunctious, and often throws bottles at foes.
  *
  * @name Pirate
  * @physical
  * @tank
  * @special Bottles
  * @itemScore con*2 + agi*1.5 + dex*1.5 - int - wis - luck*0.2
  * @statPerLevel {str} 2
  * @statPerLevel {dex} 2
  * @statPerLevel {con} 3
  * @statPerLevel {int} 1
  * @statPerLevel {wis} 2
  * @statPerLevel {agi} 1
  * @minDamage 15%
  * @category Classes
  * @package Player
###
class Pirate extends Class

  baseHp: 150
  baseHpPerLevel: 15
  baseHpPerCon: 10

  baseMp: 100
  baseMpPerLevel: 3
  baseMpPerInt: 5

  baseConPerLevel: 3
  baseDexPerLevel: 2
  baseAgiPerLevel: 2
  baseStrPerLevel: 2
  baseIntPerLevel: 1
  baseWisPerLevel: 1

  itemScore: (player, item) ->
    item.con*2 +
    item.agi*1.5 +
    item.dex*1.5 +
    item.str -
    item.int -
    item.wis -
    item.luck*0.2

  physicalAttackChance: -> -10

  minDamage: (player) ->
    player.calc.damage()*0.15

  baseXpGainPerCombat: 80 # Default: 100
  baseXpGainPerOpponentLevel: 40 # Default: 50

  baseGoldGainPerCombat: 20 # 20% of exp
  baseGoldGainPerOpponentLevel: 10 # 20% of exp

  drunkPct = new RestrictedNumber 0, 100, 0

  constructor: -> @drunkPct = new RestrictedNumber 0, 100, 0

  events: {}

  load: (player) ->
    super player
    player.special.maximum = 99
    player.special.name = "Bottles"
    player.on "combat.battle.start", @events.battleStart = ->
      player.special.toMaximum()

  unload: (player) ->
    player.special.maximum = 0
    player.special.name = ""
    player.off "combat.battle.start", @events.battleStart

module.exports = exports = Pirate
