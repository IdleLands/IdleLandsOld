
Spell = require "../../../base/Spell"
_ = require "underscore"

class AntimagicArrow extends Spell
  name: "anti-magic arrow"
  stat: @stat = "special"
  @element = AntimagicArrow::element = Spell::Element.physical
  @tiers = AntimagicArrow::tiers = [
    `/**
      * This skill targets the enemy with the most mp, inflicting a moderate amount of damage and halving their mp.
      *
      * @name anti-magic arrow
      * @requirement {class} Archer
      * @requirement {Focus} 25
      * @requirement {level} 42
      * @element physical
      * @targets {enemy} 1
      * @effect Drains mp
      * @minDamage 0.4*[wis+dex]
      * @maxDamage 0.8*[wis+dex]
      * @category Archer
      * @package Spells
    */`
    {name: "anti-magic arrow", spellPower: 1, cost: 25, class: "Archer", level: 42}
  ]

  determineTargets: ->
    _.max @targetAllEnemies(), (player) -> player.mp.getValue()

  calcDamage: ->
    minStat = (@caster.calc.stats ['wis', 'dex']) * 0.4
    maxStat = (@caster.calc.stats ['wis', 'dex']) * 0.7
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName hits %targetName with an %spellName, halving MP and dealing %damage HP damage!"
    player.mp.sub Math.floor(player.mp.getValue()/2)
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = AntimagicArrow