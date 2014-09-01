
Spell = require "../../../base/Spell"
_ = require "underscore"

class SavageStab extends Spell
  name: "savage stab"
  stat: @stat = "special"
  @element = SavageStab::element = Spell::Element.physical
  @cost = SavageStab::cost = 30
  @restrictions =
    "Rogue": 45

  @canChoose = (caster) -> caster.profession.lastComboSkill in ['heartbleed', 'wombo combo']

  calcDamage: ->
    minStat = (@caster.calc.stats ['str', 'dex']) * 0.05
    maxStat = (@caster.calc.stats ['str', 'dex']) * 0.15
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