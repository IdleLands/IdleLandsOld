
Spell = require "../base/Spell"

class Fortify extends Spell
  name: "fortify"
  @element = Fortify::element = Spell::Element.buff
  @cost = Fortify::cost = 300
  @restrictions =
    "Generalist": 15

  calcDuration: -> super()+3

  determineTargets: ->
    @caster

  calcDamage: ->
    Math.floor @caster.hp.getValue() * 0.1

  cast: (player) ->
    message = "#{@caster.name} cast #{@name}!"
    @hpBoost = @calcDamage()
    player.hp.addAndBound @hpBoost
    @broadcast message

  tick: (player) ->
    message = "#{@caster.name}'s #{@name} on #{player.name} is fading slowly!"
    @broadcastBuffMessage message

  uncast: (player) ->
    message = "#{player.name} no longer has #{@name}."
    player.hp.maximum -= @hpBoost
    player.hp.set player.hp.getValue()
    @broadcast message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = Fortify