
Spell = require "../../../base/Spell"

class BoarStrength extends Spell
  name: "boar strength"
  @element = BoarStrength::element = Spell::Element.buff
  @tiers = BoarStrength::tiers = [
    ###*
      * This spell buffs the strength of an ally.
      *
      * @name boar strength
      * @requirement {class} Cleric
      * @requirement {mp} 300
      * @requirement {level} 4
      * @effect +15% STR
      * @duration 4 rounds
      * @category Cleric
      * @package Spells
    ###
    {name: "boar strength", spellPower: 1, cost: 300, class: "Cleric", level: 4}
    ###*
      * This spell buffs the strength of an ally.
      *
      * @name demon strength
      * @requirement {class} Cleric
      * @requirement {mp} 500
      * @requirement {level} 29
      * @effect +30% STR
      * @duration 4 rounds
      * @category Cleric
      * @package Spells
    ###
    {name: "demon strength", spellPower: 2, cost: 500, class: "Cleric", level: 29}
    ###*
      * This spell buffs the strength of an ally.
      *
      * @name dragon strength
      * @requirement {class} Cleric
      * @requirement {mp} 700
      * @requirement {level} 54
      * @effect +60% STR
      * @duration 4 rounds
      * @category Cleric
      * @package Spells
    ###
    {name: "dragon strength", spellPower: 4, cost: 700, class: "Cleric", level: 54}
    ###*
      * This spell buffs the strength of an ally.
      *
      * @name titan strength
      * @requirement {class} Cleric
      * @requirement {mp} 900
      * @requirement {level} 79
      * @effect +120% STR
      * @duration 4 rounds
      * @category Cleric
      * @package Spells
    ###
    {name: "titan strength", spellPower: 8, cost: 900, class: "Cleric", level: 79}
  ]

  calcDuration: -> super()+4

  determineTargets: ->
    @targetSomeAllies()

  strPercent: -> 15*@spellPower

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