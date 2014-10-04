
Spell = require "../../../base/Spell"

class BackStab extends Spell
  name: "backstab"
  stat: @stat = "special"
  @element = BackStab::element = Spell::Element.physical
  @cost = BackStab::cost = 15
  @restrictions =
    "Rogue": 8

  @canChoose = (caster) -> caster.profession.lastComboSkill in ['opening strike']

  calcDamage: ->
    minStat = (@caster.calc.stats ['str', 'dex'] / 2) * 0.8
    maxStat = (@caster.calc.stats ['str', 'dex'] / 2) * 1.1
    super() + @minMax minStat, maxStat

  cast: (player) ->
    @caster.profession.updateCombo @

    damage = @calcDamage()
    message = "%casterName used %spellName on %targetName and dealt %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = BackStab