
Spell = require "../../../base/Spell"

class BoarStrength extends Spell
  name: "boar strength"
  @element = BoarStrength::element = Spell::Element.buff
  @tiers = BoarStrength::tiers = [
    {name: "boar strength", spellPower: 1, cost: 300, class: "Cleric", level: 4}
    {name: "demon strength", spellPower: 2, cost: 500, class: "Cleric", level: 29}
    {name: "dragon strength", spellPower: 4, cost: 700, class: "Cleric", level: 54}
    {name: "titan strength", spellPower: 8, cost: 900, class: "Cleric", level: 79}
  ]

  calcDuration: -> super()+4

  determineTargets: ->
    @targetSomeAllies()

  strPercent: -> 15*@spellPower

  cast: (player) ->
    message = "%casterName infused %targetName with %spellName!"
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

module.exports = exports = BoarStrength