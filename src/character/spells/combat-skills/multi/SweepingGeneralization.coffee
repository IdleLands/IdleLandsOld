
Spell = require "../../../base/Spell"

class SweepingGeneralization extends Spell
  name: "sweeping generalization"
  @element = SweepingGeneralization::element = Spell::Element.physical
  @tiers = SweepingGeneralization::tiers = [
    `/**
      * This skill attacks all enemies with a sweeping generalization.
      *
      * @name sweeping generalization
      * @requirement {class} Generalist
      * @requirement {mp} 350
      * @requirement {level} 5
      * @element physical
      * @targets {enemy} all
      * @minDamage 1.7*[str+dex]/4
      * @maxDamage 1.7*[str+dex]/2
      * @category Generalist
      * @package Spells
    */`
    {name: "sweeping generalization", spellPower: 1.7, cost: 350, class: "Generalist", level: 5}
    `/**
     * This skill attacks all enemies with a sweeping generalization.
     *
     * @name sweepo generalizo
     * @requirement {class} MagicalMonster
     * @requirement {mp} 600
     * @requirement {level} 15
     * @element physical
     * @targets {enemy} all
     * @minDamage 1.3*[str+dex]/4
     * @maxDamage 1.3*[str+dex]/2
     * @category MagicalMonster
     * @package Spells
     */`
    {name: "sweepo generalizo", spellPower: 1.3, cost: 600, class: "MagicalMonster", level: 15}
  ]

  calcDamage: ->
    minStat = (@caster.calc.stats ['str', 'dex'])/4
    maxStat = (@caster.calc.stats ['str', 'dex'])/2
    super() + @spellPower * @minMax minStat, maxStat

  determineTargets: ->
    @targetAllEnemies()

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName cast %spellName and %targetName took %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = SweepingGeneralization
