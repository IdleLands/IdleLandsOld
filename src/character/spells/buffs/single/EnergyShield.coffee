
Spell = require "../../../base/Spell"

class EnergyShield extends Spell
  name: "energy shield"
  @element = EnergyShield::element = Spell::Element.buff
  @tiers = EnergyShield::tiers = [
    {name: "energy shield",       spellPower: 2,  cost: 300,   class: "Mage", level: 4}
    {name: "energy buckler",      spellPower: 4,  cost: 1500,  class: "Mage", level: 29}
    {name: "energy towershield",  spellPower: 6,  cost: 2700,  class: "Mage", level: 54}
    {name: "energy giantshield",  spellPower: 10, cost: 3900,  class: "Mage", level: 79}
  ]

  calcDuration: -> super()+3+@spellPower

  determineTargets: ->
    @targetSomeAllies()

  damageReduction: -> 50 * @spellPower * @spellPower

  cast: (player) ->
    message = "%casterName gave %targetName %spellName!"
    @broadcast player, message

  tick: (player) ->
    message = "%casterName's %spellName on %targetName is fading slowly!"
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

module.exports = exports = EnergyShield