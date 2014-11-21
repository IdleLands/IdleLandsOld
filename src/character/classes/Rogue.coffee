
Class = require "./../base/Class"

###*
  * This class performs many deadly combos on its foes. Beware the finishing blow.
  *
  * @name Rogue
  * @physical
  * @dps
  * @special Stamina
  * @itemScore con*2 + agi*1.5 + dex*1.5 - int - wis - luck*0.2
  * @statPerLevel {str} 2
  * @statPerLevel {dex} 4
  * @statPerLevel {con} 2
  * @statPerLevel {int} 1
  * @statPerLevel {wis} 0
  * @statPerLevel {agi} 4
  * @minDamage 37%
  * @category Classes
  * @package Player
###
class Rogue extends Class

  baseHp: 70
  baseHpPerLevel: 10
  baseHpPerCon: 6

  baseMp: 0
  baseMpPerLevel: 1
  baseMpPerInt: 1

  baseConPerLevel: 2
  baseDexPerLevel: 4
  baseAgiPerLevel: 4
  baseStrPerLevel: 2
  baseIntPerLevel: 1
  baseWisPerLevel: 0

  itemScore: (player, item) ->
    item.agi*1.4 +
    item.dex*1.4 +
    item.str*0.3 +
    item.con*0.2 -
    item.wis*0.8 -
    item.int*0.8

  physicalAttackChance: -> -40

  minDamage: (player) ->
    player.calc.damage()*0.37

  updateCombo: (spell) ->
    @lastComboSkill = spell.baseName
    @lastComboSkillTurn = 4

  resetCombo: ->
    @lastComboSkill = null
    @lastComboSkillTurn = 0

  events: {}

  load: (player) ->
    super player
    player.special.maximum = 100
    player.special.__current = 100
    player.special.name = "Stamina"

    player.on "combat.battle.start", @events.combatStart = =>
      @resetCombo()
      player.special.toMaximum()

    player.on "combat.round.start", @events.roundStart = =>
      player.special.add 2
      @lastComboSkillTurn--  if @lastComboSkillTurn > 0
      @lastComboSkill = null if @lastComboSkillTurn <= 0

  unload: (player) ->
    player.special.maximum = 0
    player.special.name = ""

    player.off "combat.battle.start", @events.combatStart
    player.off "combat.round.start", @events.roundStart

module.exports = exports = Rogue
