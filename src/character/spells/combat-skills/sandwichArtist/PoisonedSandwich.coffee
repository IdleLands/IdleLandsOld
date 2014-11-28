
Spell = require "../../../base/Spell"
SandwichBuff = require "./SandwichBuff.coffee"

class PoisonedSandwich extends Spell
  name: "poisoned sandwich"
  @element = PoisonedSandwich::element = Spell::Element.physical
  @tiers = PoisonedSandwich::tiers = [
    `/**
      * This skill does some damage over time to 1-2 targets.
      *
      * @name poisoned sandwich
      * @requirement {class} SandwichArtist
      * @requirement {mp} 200
      * @requirement {level} 10
      * @element physical
      * @targets {enemy} 1-2
      * @duration 1+[con<250]+[con<500] round[s]
      * @minDamage [dex/6]
      * @maxDamage [dex/4]
      * @category SandwichArtist
      * @package Spells
    */`
    {name: "poisoned sandwich", spellPower: 1, cost: 200, class: "SandwichArtist", level: 10}
  ]

# Duration 1 at con >500, 2 at con 251-500, 3 at con <= 250
  calcDuration: (player) -> 1 + (player.calc.con < 500) + (player.calc.con < 250)
  
  calcDamage: ->
    minStat = (@caster.calc.stat 'dex')/6
    maxStat = (@caster.calc.stat 'dex')/4
    super() + @minMax minStat, maxStat

  determineTargets: ->
    @targetSomeEnemies size: @chance.integer({min: 1, max: 2})

  cast: (player) ->
    buff = @game.spellManager.modifySpell new SandwichBuff @game, @caster
    buff.prepareCast player
    buff.name = "poisoned #{buff.name}"
    @name = buff.name
    damage = @calcDamage()
    message = "%casterName made %targetName a %spellName and dealt %damage damage!"
    @doDamageTo player, damage, message

  tick: (player) ->
    damage = @calcDamage()
    message = "%targetName feels sick from eating %casterName's \"%spellName\", and loses %damage HP."
    @doDamageTo player, damage, message

  uncast: (player) ->
    message = "%targetName is no longer poisoned by %casterName's \"%spellName.\""
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = PoisonedSandwich