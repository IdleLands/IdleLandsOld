
Spell = require "../../../base/Spell"

class FleeInTerror extends Spell
  name: "Flee In Terror"
  @element = FleeInTerror::element = Spell::Element.energy
  @tiers = FleeInTerror::tiers = [
    {name: "Flee In Terror", spellPower: 1, cost: 300, class: "Bard", level: 0}
  ]

  calcDuration: -> super()+1+@spellPower

  fleePercent: -> 50

  determineTargets: ->
    @targetAllEnemies()

  init: ->
    message = "%casterName begins playing \"%spellName!\""
    @broadcast @caster, message

  tick: (player) ->
    message = "%targetName is terrified by %casterName's \"%spellName!\""
    @broadcast player, message

  uncast: (player) ->
    message = "%targetName is no longer under the effects of \"%spellName.\""
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellInit: @init
      doSpellUncast: @uncast
      "combat.round.start": @tick

module.exports = exports = FleeInTerror