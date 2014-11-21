
Spell = require "../../../base/Spell"

class Tranquility extends Spell
  name: "tranquility"
  stack: "intensity"
  @element = Tranquility::element = Spell::Element.holy
  @tiers = Tranquility::tiers = [
    ###*
      * This spell prevents all damage from happening for a few rounds.
      *
      * @name tranquility
      * @requirement {class} Cleric
      * @requirement {mp} 2000
      * @requirement {level} 50
      * @effect no damage
      * @category Cleric
      * @package Spells
    ###
    {name: "tranquility", spellPower: 1, cost: 2000, class: "Cleric", level: 50}
  ]

  calcDuration: -> super()+1+@spellPower

  damageMultiplier: -> -1

  determineTargets: ->
    @targetAll()

  init: ->
    message = "%casterName cast %spellName!"
    @broadcast @caster, message

  tick: (player) ->
    message = "%targetName is still under the effects of %casterName's \"%spellName!\""
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

module.exports = exports = Tranquility
