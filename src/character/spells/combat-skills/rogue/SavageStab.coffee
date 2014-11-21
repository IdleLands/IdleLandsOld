
Spell = require "../../../base/Spell"
_ = require "underscore"

class SavageStab extends Spell
  name: "savage stab"
  stat: @stat = "special"
  @element = SavageStab::element = Spell::Element.physical
  @tiers = SavageStab::tiers = [
    ###*
      * This skill does very little damage, but leaves every combat effect available on the target.
      * Currently, it will only prone the target. Poison and other effects may happen later.
      *
      * @name savage stab
      * @requirement {class} Rogue
      * @requirement {Stamina} 30
      * @requirement {level} 45
      * @prerequisite {used-skill} wombo combo
      * @prerequisite {used-skill} heartbleed
      * @minDamage 0.05*[str+dex]/2
      * @maxDamage 0.15*[str+dex]/2
      * @category Rogue
      * @package Spells
    ###
    {name: "savage stab", spellPower: 1, cost: 30, class: "Rogue", level: 45}
  ]

  @canChoose = (caster) -> caster.profession.lastComboSkill in ['heartbleed', 'wombo combo']

  calcDamage: ->
    minStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 0.05
    maxStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 0.15
    super() + @minMax minStat, maxStat

  cast: (player) ->
    @caster.profession.updateCombo @

    damage = @calcDamage()
    message = "%casterName used %spellName on %targetName and dealt %damage HP damage!"
    @doDamageTo player, damage, message

    effects = []
    effects.push effect.name for effect in @game.spellManager.getStatusEffects()

    @caster.party?.currentBattle?.doBattleEffects effects, @caster, player

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = SavageStab