
Spell = require "../../../base/Spell"

class Treatment extends Spell
  name: "treatment"
  @element = Treatment::element = Spell::Element.heal & Spell::Element.buff
  @cost = Treatment::cost = 400
  @restrictions =
    "Generalist": 7

  calcDuration: -> super()+3

  determineTargets: ->
    @targetSomeAllies()

  calcDamage: (player) ->
    Math.floor (player.hp.maximum * 0.1)

  cast: (player) ->
    message = "%casterName began treating %targetName's wounds with %spellName!"
    @broadcast player, message

  uncast: (player) ->
    message = "%casterName is no longer treating %targetName with %spellName."
    @broadcast player, message

  tick: (player) ->
    restored = @calcDamage player
    message = "%casterName's %spellName restored #{restored} HP for %targetName!"
    @doDamageTo player, -restored
    @broadcastBuffMessage player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      "combat.self.turn.end": @tick
      doSpellCast: @cast
      doSpellUncast: @uncast

module.exports = exports = Treatment