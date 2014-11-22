Spell = require "../../../base/Spell"

class Testosterone extends Spell
  name: "testosterone"
  @element = Testosterone::element = Spell::Element.buff
  @tiers = Testosterone::tiers = [
    `/**
      * This spell buffs the strength of the caster dramatically.
      *
      * @name Testosterone
      * @requirement {class} Fighter
      * @requirement {mp} 300
      * @requirement {level} 4
      * @effect +35% STR
      * @duration 4 rounds
      * @category Fighter
      * @package Spells
    */`
    {name: "testosterone", spellPower: 1, cost: 300, class: "Fighter", level: 4}
  ]

  calcDuration: -> super()+4

  determineTargets: ->
    @caster
    
  strPercent: -> 35

  cast: (player) ->
    message = "%casterName infused %himherself with %spellName!"
    @broadcast player, message

  tick: (player) ->
    message = "%casterName's %spellName is fading slowly!"
    @broadcastBuffMessage player, message

  uncast: (player) ->
    message = "%targetName no longer has %spellName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = Testosterone
