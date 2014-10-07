
Spell = require "../../../base/Spell"

class LightsFromTheStars extends Spell
  name: "Lights from the Stars"
  @element = LightsFromTheStars::element = Spell::Element.buff
  @tiers = LightsFromTheStars::tiers = [
    {name: "Lights from the Stars", spellPower: 1, cost: 300, class: "Bard", level: 10}
  ]

  calcDuration: -> super()+3

  determineTargets: ->
    @targetAllAllies()

  int: -> @storedInt
  
  wis: -> @storedWis

  init: ->
    @storedInt = (@caster.calc.stat 'int')/4
    @storedWis = (@caster.calc.stat 'wis')/4
    message = "%casterName begins playing \"%spellName!\""
    @broadcast @caster, message

  tick: (player) ->
    return if @caster isnt player
    message = "%casterName still calls power from the celestial bodies for %hisher teammates with \"%spellName!\""
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

module.exports = exports = LightsFromTheStars