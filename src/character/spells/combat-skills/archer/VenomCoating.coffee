
Spell = require "../../../base/Spell"

class VenomCoating extends Spell
  name: "venom coating"
  @element = VenomCoating::element = Spell::Element.physical
  @tiers = VenomCoating::tiers = [
    `/**
      * This spell gives the caster poison and venom temporarily. Only used at low Focus.
      *
      * @name VenomCoating
      * @requirement {class} Archer
      * @requirement {mp} 150
      * @requirement {level} 15
      * @requirement {Focus} < 40
      * @element physical
      * @targets {self}
      * @effect venom, poison
      * @duration 4 rounds
      * @category Archer
      * @package Spells
    */`
    {name: "venom coating", spellPower: 1, cost: 150, class: "Archer", level: 15}
  ]

  @canChoose = (caster) -> (not (caster.calc.venom() or caster.calc.poison())) and caster.special.getValue() < 40

  calcDuration: (player) -> super()+4

  venom: -> 1
  poison: -> 1

  determineTargets: -> @caster

  cast: (player) ->
    message = "%casterName gives %hisher arrows a %spellName!"
    @broadcast player, message

  tick: (player) ->
    message = "%casterName's arrows are tipped with venom."

  uncast: (player) ->
    message = "%casterName's arrows lose their %spellName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = VenomCoating