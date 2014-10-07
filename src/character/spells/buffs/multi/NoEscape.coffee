
Spell = require "../../../base/Spell"

class NoEscape extends Spell
  name: "No Escape"
  @element = NoEscape::element = Spell::Element.buff
  @tiers = NoEscape::tiers = [
    {name: "No Escape", spellPower: 1, cost: 300, class: "Bard", level: 5}
  ]

  calcDuration: -> super()+3

  determineTargets: ->
    @targetAllAllies()

  dex: -> @storedInt
  
  agi: -> @storedWis

  init: ->
    @storedInt = (@caster.calc.stat 'int')/4
    @storedWis = (@caster.calc.stat 'wis')/4
    message = "%casterName begins playing \"%spellName!\""
    @broadcast @caster, message

  tick: (player) ->
    return if @caster isnt player
    message = "%casterName cheers on %hisher teammates to not lose sight of their foes with \"%spellName!\""
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

module.exports = exports = NoEscape