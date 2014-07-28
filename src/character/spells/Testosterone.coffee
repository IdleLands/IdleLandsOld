Spell = require "../base/Spell"

class Testosterone extends Spell
  name: "testosterone"
  @element = Testosterone::element = Spell::Element.buff
  @cost = Testosterone::cost = 300
  @restrictions =
    "Fighter": 4

  calcDuration: -> super()+2

  determineTargets: ->
    @caster
    
  strPercent: -> 35

  cast: (player) ->
    message = "#{@caster.name} infused #{player.name} with #{@name}!"
    @broadcastBuffMessage message

  tick: (player) ->
    message = "#{@caster.name}'s #{@name} on #{player.name} is fading slowly!"
    @broadcastBuffMessage message

  uncast: (player) ->
    message = "#{player.name} no longer has #{@name}."
    @broadcast message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = Testosterone
