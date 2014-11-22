
Spell = require "../../../base/Spell"

class OurHeartsIgnite extends Spell
  name: "Our Hearts Ignite"
  @element = OurHeartsIgnite::element = Spell::Element.buff
  @tiers = OurHeartsIgnite::tiers = [
    `/**
      * This spell buffs the str and con of your allies.
      *
      * @name Our Hearts Ignite
      * @requirement {class} Bard
      * @requirement {mp} 300
      * @requirement {level} 1
      * @effect +[caster.int/4] str
      * @effect +[caster.wis/4] con
      * @duration 3 rounds
      * @category Bard
      * @package Spells
    */`
    {name: "Our Hearts Ignite", spellPower: 1, cost: 300, class: "Bard", level: 1}
  ]

  calcDuration: -> super()+3

  determineTargets: ->
    @targetAllAllies()

  str: -> @storedInt
  
  con: -> @storedWis

  init: ->
    @storedInt = (@caster.calc.stat 'int')/4
    @storedWis = (@caster.calc.stat 'wis')/4
    message = "%casterName begins playing \"%spellName!\""
    @broadcast @caster, message

  tick: (player) ->
    return if @caster isnt player
    message = "%casterName continues to ignite the hearts of %hisher teammates with \"%spellName!\""
    @broadcastBuffMessage player, message

  uncast: (player) ->
    return if @caster isnt player
    message = "%casterName finishes \"%spellName.\""
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellInit: @init
      doSpellUncast: @uncast
      "combat.round.end": @tick

module.exports = exports = OurHeartsIgnite