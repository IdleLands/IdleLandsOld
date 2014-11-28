
Spell = require "../../../base/Spell"

class OpeningStrike extends Spell
  name: "opening strike"
  stat: @stat = "special"
  @element = OpeningStrike::element = Spell::Element.physical
  @tiers = OpeningStrike::tiers = [
    `/**
      * This skill does a moderate amount of damage, but starts the combo for the Rogue.
      *
      * @name opening strike
      * @requirement {class} Rogue
      * @requirement {Stamina} 10
      * @requirement {level} 1
      * @element physical
      * @targets {enemy} 1
      * @minDamage 0.5*[str+dex]/2
      * @maxDamage 0.75*[str+dex]/2
      * @category Rogue
      * @package Spells
    */`
    {name: "opening strike", spellPower: 1, cost: 10, class: "Rogue", level: 1}
  ]

  @canChoose = (caster) -> caster.profession.lastComboSkillTurn <= 0

  calcDamage: ->
    minStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 0.5
    maxStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 0.75
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

module.exports = exports = OpeningStrike