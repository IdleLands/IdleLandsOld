
Spell = require "../../../base/Spell"

class BoarStrength extends Spell
  name: "boar strength"
  @element = BoarStrength::element = Spell::Element.buff
  @cost = BoarStrength::cost = 300
  @restrictions =
    "Cleric": 4

  calcDuration: -> super()+4

  determineTargets: ->
    @targetSomeAllies()

  strPercent: -> 15

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