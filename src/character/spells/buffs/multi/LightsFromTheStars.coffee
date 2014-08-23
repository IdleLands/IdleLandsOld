
Spell = require "../../../base/Spell"

class LightsFromTheStars extends Spell
  name: "Lights from the Stars"
  @element = LightsFromTheStars::element = Spell::Element.buff
  @cost = LightsFromTheStars::cost = 300
  @restrictions =
    "Bard": 10

  calcDuration: -> super()+3

  determineTargets: ->
    @targetAllAllies()

  int: -> @storedInt
  
  wis: -> @storedWis

  cast: (player) ->
    @storedInt = (@caster.calc.stat 'int')/4
    @storedWis = (@caster.calc.stat 'wis')/4
    return if @caster isnt player
    message = "#{@caster.name} begins playing \"#{@name}!\""
    @broadcast message

  tick: (player) ->
    return if @caster isnt player
    message = "#{@caster.name} still calls power from the celestial bodies for %hisher teammates!"
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

module.exports = exports = LightsFromTheStars