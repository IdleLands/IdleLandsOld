
_ = require "underscore"
Spell = require "../../../base/Spell"

class FrostBite extends Spell
  name: "frostbite"
  @element = FrostBite::element = Spell::Element.ice
  @tiers = FrostBite::tiers = [
    `/**
      * This spell does some damage, and has a small chance to stun for a few rounds afterwards.
      *
      * @name frostbite
      * @requirement {class} Mage
      * @requirement {mp} 100
      * @requirement {level} 5
      * @element ice
      * @targets {enemy} 1
      * @minDamage [int/6]
      * @maxDamage [int/4]
      * @duration 3 rounds
      * effect {25%-chance} STUN
      * @category Mage
      * @package Spells
    */`
    {name: "frostbite", spellPower: 100, cost: 100, class: "Mage", level: 4}
  ]

  cantAct: -> if @chance.bool({likelihood:25}) then 1 else 0

  cantActMessages: -> "%player is currently frostbitten"

  calcDuration: -> super()+3

  calcDamage: ->
    minStat = (@caster.calc.stat 'int')/6
    maxStat = (@caster.calc.stat 'int')/4
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName cast %spellName at %targetName for %damage HP damage!"
    @doDamageTo player, damage, message

  tick: (player) ->
    message = "%targetName is still suffering from %spellName."
    @broadcastBuffMessage player, message

  uncast: (player) ->
    message = "%targetName is no longer suffering from %spellName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = FrostBite
