
Spell = require "../../../base/Spell"

class Fortify extends Spell
  name: "fortify"
  @element = Fortify::element = Spell::Element.buff
  @tiers = Fortify::tiers = [
    {name: "fortify", spellPower: 1, cost: 300, class: "Generalist", level: 15}
  ]

  calcDuration: -> super()+7

  determineTargets: ->
    @caster

  calcDamage: ->
    Math.floor @caster.hp.getValue() * 0.2

  cast: (player) ->
    message = "%casterName cast %spellName!"
    @hpBoost = @calcDamage()
    player.hp.addAndBound @hpBoost
    @broadcast player, message

  tick: (player) ->
    message = "%casterName's %spellName is fading slowly!"
    @broadcastBuffMessage player, message

  uncast: (player) ->
    message = "%targetName no longer has %spellName."
    player.hp.maximum -= @hpBoost
    player.hp.set player.hp.getValue()
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = Fortify