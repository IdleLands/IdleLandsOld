
Spell = require "../../../base/Spell"

class BoarStrength extends Spell
  name: "boar strength"
  @element = BoarStrength::element = Spell::Element.buff
  @cost = BoarStrength::cost = 300
  @restrictions =
    "Cleric": 4

  calcDuration: -> super()+3

  determineTargets: ->
    @targetSomeAllies()

  strPercent: -> 25

  cast: (player) ->
    message = "#{@caster.name} infused #{player.name} with #{@name}!"
    @broadcast message

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

module.exports = exports = BoarStrength