
Spell = require "../base/Spell"

class OurHeartsIgnite extends Spell
  name: "Our Hearts Ignite"
  @element = OurHeartsIgnite::element = Spell::Element.buff
  @cost = OurHeartsIgnite::cost = 300
  @restrictions =
    "Bard": 1

  calcDuration: -> super()+3

  determineTargets: ->
    @targetFriendlies()

  str: -> (@caster.calc.stat 'int')/4
  
  con: -> (@caster.calc.stat 'wis')/4

  cast: (player) ->
    return if @caster isnt player
    message = "#{@caster.name} begins playing \"#{@name}!\""
    @broadcast message

  tick: (player) ->
    return if @caster isnt player
    message = "#{@caster.name} continues to ignite the hearts of %hisher teammates!"
    @broadcastBuffMessage message

  uncast: (player) ->
    return if @caster isnt player
    message = "#{@caster.name} finishes \"#{@name}.\""
    @broadcast message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = OurHeartsIgnite