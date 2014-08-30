
Spell = require "../../../base/Spell"

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
    message = "%casterName used %spellName on %targetName and dealt %damage HP damage!"
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

module.exports = exports = BluntHit
