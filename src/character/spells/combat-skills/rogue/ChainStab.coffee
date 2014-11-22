
Spell = require "../../../base/Spell"

class ChainStab extends Spell
  name: "chain stab"
  stat: @stat = "special"
  @element = ChainStab::element = Spell::Element.physical
  @tiers = ChainStab::tiers = [
    `/**
      * This skill does a small amount of damage, but can repeat itself.
      *
      * @name chain stab
      * @requirement {class} Rogue
      * @requirement {Stamina} 10
      * @requirement {level} 3
      * @prerequisite {used-skill} chain stab
      * @prerequisite {used-skill} opening strike
      * @prerequisite {used-skill} backstab
      * @minDamage 0.3*[str+dex]/2
      * @maxDamage 0.5*[str+dex]/2
      * @category Rogue
      * @package Spells
    */`
    {name: "chain stab", spellPower: 1, cost: 10, class: "Rogue", level: 3}
  ]

  @canChoose = (caster) -> caster.profession.lastComboSkill in ['opening strike', 'chain stab', 'backstab']

  calcDamage: ->
    minStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 0.3
    maxStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 0.5
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

module.exports = exports = ChainStab
