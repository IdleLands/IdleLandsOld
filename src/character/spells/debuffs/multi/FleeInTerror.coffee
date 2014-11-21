
Spell = require "../../../base/Spell"

class FleeInTerror extends Spell
  name: "Flee In Terror"
  @element = FleeInTerror::element = Spell::Element.energy
  @tiers = FleeInTerror::tiers = [
    ###*
      * This spell causes the enemies to want to flee.
      *
      * @name Flee In Terror
      * @requirement {class} Bard
      * @requirement {mp} 2000
      * @requirement {level} 50
      * @effect +50% flee chance
      * @duration 2 rounds
      * @category Bard
      * @package Spells
    ###
    {name: "Flee In Terror", spellPower: 1, cost: 2000, class: "Bard", level: 50}
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