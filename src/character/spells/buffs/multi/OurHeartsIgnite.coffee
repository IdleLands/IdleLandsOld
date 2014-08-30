
Spell = require "../../../base/Spell"

class OurHeartsIgnite extends Spell
  name: "Our Hearts Ignite"
  @element = OurHeartsIgnite::element = Spell::Element.buff
  @cost = OurHeartsIgnite::cost = 300
  @restrictions =
    "Bard": 1

  calcDuration: -> super()+3

  determineTargets: ->
    @targetAllAllies()

  str: -> (@caster.calc.stat 'int')/4
  
  con: -> (@caster.calc.stat 'wis')/4

  cast: (player) ->
    return if @caster isnt player
    message = "%casterName begins playing \"%spellName!\""
    @broadcast player, message

  tick: (player) ->
    return if @caster isnt player
    message = "%casterName continues to ignite the hearts of %hisher teammates!"
    @broadcastBuffMessage player, message

  uncast: (player) ->
    return if @caster isnt player
    message = "%casterName finishes \"%spellName.\""
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = OurHeartsIgnite