
Spell = require "../../../base/Spell"

class Vampire extends Spell
  @name = Vampire::name = "vampirism"
  @element = Vampire::element = Spell::Element.physical
  @isStatusEffect = yes

  calcDuration: -> @caster.calc.stat 'vampire'

  calcDamage: (victim) ->
    parseInt (victim.hp.maximum * 0.02)

  tick: (player) ->
    damage = @calcDamage player
    message = "%targetName is still affected by %spellName and lost %damage HP#{if @caster.hp.atMin() then '' else ' to %casterName'}!"
    @doDamageTo player, damage, message
    @doDamageTo @caster, -damage, '' if not @caster.hp.atMin()

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

module.exports = exports = Vampire
