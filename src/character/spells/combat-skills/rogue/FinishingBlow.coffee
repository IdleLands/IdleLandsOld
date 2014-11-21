
Spell = require "../../../base/Spell"

class FinishingBlow extends Spell
  name: "finishing blow"
  stat: @stat = "special"
  @element = FinishingBlow::element = Spell::Element.physical
  @cost = FinishingBlow::cost = 30
  @restrictions =
    "Rogue": 38
  @tiers = FinishingBlow::tiers = [
    ###*
      * This skill does a massive amount of damage, and finishes the rogue combo.
      *
      * @name finishing blow
      * @requirement {class} Rogue
      * @requirement {Stamina} 30
      * @requirement {level} 38
      * @prerequisite {used-skill} savage stab
      * @prerequisite {used-skill} wombo combo
      * @minDamage 2.0*[str+dex]/2
      * @maxDamage 2.5*[str+dex]/2
      * @category Rogue
      * @package Spells
    ###
    {name: "finishing blow", spellPower: 1, cost: 30, class: "Rogue", level: 38}
  ]

  @canChoose = (caster) -> caster.profession.lastComboSkill in ['wombo combo', 'savage stab']

  calcDamage: ->
    minStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 2
    maxStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 2.5
    super() + @minMax minStat, maxStat

  cast: (player) ->
    @caster.profession.updateCombo @

    damage = @calcDamage()
    message = "%casterName used %spellName on %targetName and dealt %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = FinishingBlow
