Spell = require "../../../base/Spell"

class Testosterone extends Spell
  name: "testosterone"
  @element = Testosterone::element = Spell::Element.buff
  @cost = Testosterone::cost = 300
  @restrictions =
    "Fighter": 4

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
