
Spell = require "../../../base/Spell"

class TakeAim extends Spell
  name: "take aim"
  @element = TakeAim::element = Spell::Element.physical
  @tiers = TakeAim::tiers = [
    `/**
      * The caster takes aim, increasing their Focus. Can only be used when at low Focus.
      *
      * @name hurricane
      * @requirement {class} Archer
      * @requirement {mp} 35
      * @requirement {level} 7
      * @requirement {Focus} < 50
      * @element physical
      * @targets {self}
      * @effect +50 focus
      * @category Archer
      * @package Spells
    */`
    {name: "take aim", spellPower: 1, cost: 35, class: "Archer", level: 7}
  ]

  @canChoose = (caster) -> caster.special.getValue() < 50

  determineTargets: -> @caster

  cast: (player) ->
    message = "%targetName takes aim!"
    @broadcast player, message
    player.special.add 50

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = TakeAim