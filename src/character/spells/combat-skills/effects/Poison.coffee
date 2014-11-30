
Spell = require "../../../base/Spell"

class Poison extends Spell
  @name = Poison::name = "poison"
  @element = Poison::element = Spell::Element.physical
  @isStatusEffect = yes

  calcDuration: -> 3

  calcDamage: ->
    minStat = (@caster.calc.stat 'wis') / 10
    maxStat = (@caster.calc.stat 'wis') / 6
    super() + @minMax minStat, maxStat

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

module.exports = exports = Poison
