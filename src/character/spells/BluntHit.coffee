
Spell = require "../base/Spell"

class BluntHit extends Spell
  name: "blunt hit"
  @element = BluntHit::element = Spell::Element.physical
  @cost = BluntHit::cost = 100
  @restrictions =
    "Fighter": 13

  cantAct: -> 1

  cantActMessages: -> "%player is currently stunned"

  calcDuration: -> super()+1

  calcDamage: ->
    minStat = (@caster.calc.stat 'str')/6
    maxStat = (@caster.calc.stat 'str')/4
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} used #{@name} on #{player.name} and dealt %damage HP damage!"
    @doDamageTo player, damage, message

  tick: (player) ->
    message = "#{player.name} is still suffering from #{@name}."
    @broadcastBuffMessage message

  uncast: (player) ->
    message = "#{player.name} is no longer suffering from #{@name}."
    @broadcast message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = BluntHit
