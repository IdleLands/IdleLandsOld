
Spell = require "../../../base/Spell"

class Shatter extends Spell
  @name = Shatter::name = "shatter"
  @element = Shatter::element = Spell::Element.physical
  @isStatusEffect = yes

  conPercent: -30
  dexPercent: -30
  agiPercent: -30

  calcDuration: -> 3

  calcDamage: -> 0

  tick: (player) ->
    message = "%targetName is still suffering from %spellName."
    @broadcastBuffMessage player, message

  cast: (player) ->
    message = "%targetName had %hisher defenses shattered!"
    @broadcast player, message

  uncast: (player) ->
    message = "%targetName's defenses have recovered."
    @broadcast player, message

  constructor: (@game, @caster, forced) ->
    super @game, @caster, forced
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = Shatter
