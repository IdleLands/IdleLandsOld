
Spell = require "../../../base/Spell"

class Venom extends Spell
  @name = Venom::name = "venom"
  @element = Venom::element = Spell::Element.physical
  @isStatusEffect = yes

  calcDuration: -> 2

  calcDamage: (victim) ->
    parseInt (victim.hp.maximum * 0.04)

  tick: (player) ->
    damage = @calcDamage player
    message = "%targetName is still affected by %spellName and lost %damage HP!"
    @doDamageTo player, damage, message

  cast: (player) ->
    message = "%targetName was afflicted with %spellName!"
    @broadcast player, message

  uncast: (player) ->
    message = "%targetName has recovered from %spellName."
    @broadcast player, message

  constructor: (@game, @caster, forced) ->
    super @game, @caster, forced
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = Venom
