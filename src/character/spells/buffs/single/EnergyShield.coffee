
Spell = require "../../../base/Spell"

class EnergyShield extends Spell
  name: "energy shield"
  @element = EnergyShield::element = Spell::Element.buff
  @tiers = EnergyShield::tiers = [
    `/**
      * This spell reduces incoming damage for a period of time.
      *
      * @name energy shield
      * @requirement {class} Mage
      * @requirement {mp} 300
      * @requirement {level} 4
      * @element buff
      * @targets {ally} 1
      * @effect -100 damage
      * @duration 9 rounds
      * @category Mage
      * @package Spells
    */`
    {name: "energy shield",       spellPower: 2,  cost: 300,   class: "Mage", level: 4}
    `/**
      * This spell reduces incoming damage for a period of time.
      *
      * @name energy buckler
      * @requirement {class} Mage
      * @requirement {mp} 1000
      * @requirement {level} 29
      * @element buff
      * @targets {ally} 1
      * @effect -400 damage
      * @duration 7 rounds
      * @category Mage
      * @package Spells
    */`
    {name: "energy buckler",      spellPower: 4,  cost: 1000,  class: "Mage", level: 29}
    `/**
      * This spell reduces incoming damage for a period of time.
      *
      * @name energy towershield
      * @requirement {class} Mage
      * @requirement {mp} 2300
      * @requirement {level} 54
      * @element buff
      * @targets {ally} 1
      * @effect -900 damage
      * @duration 5 rounds
      * @category Mage
      * @package Spells
    */`
    {name: "energy towershield",  spellPower: 6,  cost: 2300,  class: "Mage", level: 54}
    `/**
      * This spell reduces incoming damage for a period of time.
      *
      * @name energy omegashield
      * @requirement {class} Mage
      * @requirement {mp} 7900
      * @requirement {level} 79
      * @element buff
      * @targets {ally} 1
      * @effect -2500 damage
      * @duration 1 round
      * @category Mage
      * @package Spells
    */`
    {name: "energy omegashield",  spellPower: 10, cost: 7900,  class: "Mage", level: 79}
    `/**
      * This spell reduces incoming damage for a period of time.
      *
      * @name energy barrier
      * @requirement {class} Generalist
      * @requirement {mp} 400
      * @requirement {level} 10
      * @element buff
      * @targets {ally} 1
      * @effect -25 damage
      * @duration 10 rounds
      * @category Generalist
      * @package Spells
    */`
    {name: "energy barrier",      spellPower: 1,  cost: 400,   class: "Generalist", level: 10}
    `/**
      * This spell reduces incoming damage for a period of time.
      *
      * @name energy field
      * @requirement {class} Generalist
      * @requirement {mp} 800
      * @requirement {level} 25
      * @element buff
      * @targets {ally} 1
      * @effect -100 damage
      * @duration 9 rounds
      * @category Generalist
      * @package Spells
    */`
    {name: "energy field",        spellPower: 2,  cost: 800,   class: "Generalist", level: 25}
    `/**
      * This spell reduces incoming damage for a period of time.
      *
      * @name energy wall
      * @requirement {class} Generalist
      * @requirement {mp} 1200
      * @requirement {level} 40
      * @element buff
      * @targets {ally} 1
      * @effect -225 damage
      * @duration 8 rounds
      * @category Generalist
      * @package Spells
    */`
    {name: "energy wall",         spellPower: 3,  cost: 1200,  class: "Generalist", level: 40}
    `/**
      * This spell reduces incoming damage for a period of time.
      *
      * @name energy barricade
      * @requirement {class} Generalist
      * @requirement {mp} 1600
      * @requirement {level} 55
      * @element buff
      * @targets {ally} 1
      * @effect -1225 damage
      * @duration 7 rounds
      * @category Generalist
      * @package Spells
    */`
    {name: "energy barricade",    spellPower: 4,  cost: 1600,  class: "Generalist", level: 55}
  ]

  calcDuration: -> super()+11-@spellPower

  determineTargets: ->
    @targetSomeAllies()

  damageReduction: -> 50 * @spellPower * (@spellPower / 2)

  cast: (player) ->
    message = "%casterName gave %targetName %spellName!"
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

module.exports = exports = EnergyShield
