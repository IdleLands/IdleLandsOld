
Spell = require "../../../base/Spell"

class VenomCoating extends Spell
  name: "venom coating"
  @element = VenomCoating::element = Spell::Element.physical
  @tiers = VenomCoating::tiers = [
    `/**
      * This spell gives one ally poison and venom temporarily. Only used at low Focus.
      *
      * @name venom coating
      * @requirement {class} Archer
      * @requirement {mp} 150
      * @requirement {level} 15
      * @requirement {Focus} < 40
      * @element physical
      * @targets {ally} 1
      * @effect venom
      * @effect poison
      * @duration 4 rounds
      * @category Archer
      * @package Spells
    */`
    {name: "venom coating", spellPower: 1, cost: 150, class: "Archer", level: 15}
  ]

  @canChoose = (caster) -> caster.special.getValue() < 40

  calcDuration: (player) -> super()+4

  venom: -> 1
  poison: -> 1

  determineTargets: -> @targetSomeAllies()

  cast: (player) ->
    message = "%casterName gives %targetName's weapon a %spellName!"
    @broadcast player, message

  tick: (player) ->
    message = "%targetName's weapon is coated with venom."

  uncast: (player) ->
    message = "%targetName's weapon loses its %spellName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = VenomCoating