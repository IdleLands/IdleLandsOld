
Spell = require "../../../base/Spell"
DazeEffect = require "../../../timedEffects/DazeEffect.coffee"
_ = require "lodash"

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
      * @targets {enemy} 1 (with most mp remaining)
      * @effect Drains mp
      * @effect Dazes for 5 minutes
      * @minDamage 0.4*[wis+dex]
      * @maxDamage 0.7*[wis+dex]
      * @category Archer
      * @package Spells
    */`
    {name: "anti-magic arrow", spellPower: 1, cost: 25, class: "Archer", level: 42}
  ]

  determineTargets: ->
    @targetHighestMp @targetAllEnemies()

  calcDamage: ->
    minStat = (@caster.calc.stats ['wis', 'dex']) * 0.4
    maxStat = (@caster.calc.stats ['wis', 'dex']) * 0.7
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName hits %targetName with an %spellName, halving %targetName's MP and dealing %damage HP damage!"

    if player.mp and player.mp.getValue() > 0
      damage = Math.floor player.mp.getValue()/2
      @caster.party?.currentBattle?.takeMp @caster, player, damage, @determineType(), @

    @doDamageTo player, damage, message

    daze = new DazeEffect
    daze.apply player, {minutes: 5}

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = AntimagicArrow