
Spell = require "../../../base/Spell"

class Treatment extends Spell
  name: "treatment"
  @element = Treatment::element = Spell::Element.heal & Spell::Element.buff
  @tiers = Treatment::tiers = [
    `/**
      * This spell heals a certain percentage of health over time.
      *
      * @name treatment
      * @requirement {class} Generalist
      * @requirement {mp} 450
      * @requirement {level} 7
      * @element heal, buff
      * @targets {ally} 1
      * @effect +15% hp
      * @duration 3 rounds
      * @category Generalist
      * @package Spells
    */`
    {name: "treatment", spellPower: 1, cost: 450, class: "Generalist", level: 7}
  ]

  calcDuration: -> super()+3

  determineTargets: ->
    @targetSomeAllies()

  calcDamage: (player) ->
    Math.floor (player.hp.maximum * 0.15)

  cast: (player) ->
    message = "%casterName began treating %targetName's wounds with %spellName!"
    @broadcast player, message

  uncast: (player) ->
    message = "%casterName is no longer treating %targetName with %spellName."
    @broadcast player, message

  tick: (player) ->
    restored = @calcDamage player
    message = "%casterName's %spellName restored #{restored} HP for %targetName!"
    @doDamageTo player, -restored
    @broadcastBuffMessage player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      "combat.self.turn.end": @tick
      doSpellCast: @cast
      doSpellUncast: @uncast

module.exports = exports = Treatment