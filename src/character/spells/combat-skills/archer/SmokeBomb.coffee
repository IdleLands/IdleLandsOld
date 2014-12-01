
Spell = require "../../../base/Spell"

class SmokeBomb extends Spell
  name: "SmokeBomb"
  @element = SmokeBomb::element = Spell::Element.physical
  @tiers = SmokeBomb::tiers = [
    `/**
      * The caster throws a smoke bomb at 1-3 enemies, reducing their DEX. Only used at low Focus.
      *
      * @name smoke bomb
      * @requirement {class} Archer
      * @requirement {mp} 80
      * @requirement {level} 10
      * @requirement {Focus} < 50
      * @element physical
      * @targets {enemy} 2-5
      * @effect -40% DEX
      * @duration 3 rounds
      * @category Archer
      * @package Spells
    */`
    {name: "smoke bomb", spellPower: 1, cost: 80, class: "Archer", level: 10}
  ]

  @canChoose = (caster) -> caster.special.getValue() < 30

  calcDuration: -> super()+3

  dexPercent: -> -40

  determineTargets: ->
    @targetSomeEnemies size: @chance.integer({min: 1, max: 3})

  cast: (player) ->
    message = "%targetName is blinded by %casterName's %spellName!"
    @broadcast player, message
    return

  tick: (player) ->
    message = "%casterName's %spellName on %targetName is fading slowly!"
    @broadcastBuffMessage player, message

  uncast: (player) ->
    message = "%targetName is no longer affected by %casterName's %spellName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = SmokeBomb