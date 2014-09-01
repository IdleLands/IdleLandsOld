
Spell = require "../../../base/Spell"

class Heartbleed extends Spell
  name: "heartbleed"
  stat: @stat = "special"
  @element = Heartbleed::element = Spell::Element.physical
  @cost = Heartbleed::cost = 15
  @restrictions =
    "Rogue": 15

  @canChoose = (caster) -> caster.profession.lastComboSkill in ['backstab', 'chain stab']

  calcDamage: ->
    minStat = (@caster.calc.stats ['str', 'dex']) * 0.3
    maxStat = (@caster.calc.stats ['str', 'dex']) * 0.7
    super() + @minMax minStat, maxStat

  calcDuration: -> super() + 2

  calcBleedDamage: (victim) ->
    parseInt (victim.hp.maximum * 0.07)

  cast: (player) ->
    @caster.profession.updateCombo @

    damage = @calcDamage()
    message = "%casterName used %spellName on %targetName and dealt %damage HP damage!"
    @doDamageTo player, damage, message

  tick: (player) ->
    damage = @calcBleedDamage player
    message = "%targetName is still affected by %spellName and lost %damage HP!"
    @doDamageTo player, damage, message

  uncast: (player) ->
    message = "%targetName is no longer suffering from %spellName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = Heartbleed