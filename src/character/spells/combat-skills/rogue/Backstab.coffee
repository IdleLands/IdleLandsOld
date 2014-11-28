
Spell = require "../../../base/Spell"

class BackStab extends Spell
  name: "backstab"
  stat: @stat = "special"
  @element = BackStab::element = Spell::Element.physical
  @tiers = BackStab::tiers = [
    `/**
      * This skill does a lot of damage to a player. It's not very nice.
      *
      * @name backstab
      * @requirement {class} Rogue
      * @requirement {Stamina} 15
      * @requirement {level} 8
      * @element physical
      * @prerequisite {used-skill} opening strike
      * @minDamage 0.8*[str+dex]/2
      * @maxDamage 1.1*[str+dex]/2
      * @category Rogue
      * @package Spells
    */`
    {name: "backstab", spellPower: 1, cost: 15, class: "Rogue", level: 8}
  ]

  @canChoose = (caster) -> caster.profession.lastComboSkill in ['opening strike']

  calcDamage: ->
    minStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 0.8
    maxStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 1.1
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

module.exports = exports = BackStab