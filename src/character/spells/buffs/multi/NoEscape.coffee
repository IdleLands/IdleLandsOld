
Spell = require "../../../base/Spell"

class NoEscape extends Spell
  name: "No Escape"
  @element = NoEscape::element = Spell::Element.buff
  @cost = NoEscape::cost = 300
  @restrictions =
    "Bard": 5

  calcDuration: -> super()+3

  determineTargets: ->
    @targetAllAllies()

  dex: -> (@caster.calc.stat 'int')/4
  
  agi: -> (@caster.calc.stat 'wis')/4

  cast: (player) ->
    return if @caster isnt player
    message = "#{@caster.name} begins playing \"#{@name}!\""
    @broadcast message

  tick: (player) ->
    return if @caster isnt player
    message = "#{@caster.name} cheers on %hisher teammates to not lose sight of their foes!"
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

module.exports = exports = NoEscape