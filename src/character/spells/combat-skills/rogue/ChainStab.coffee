
Spell = require "../../../base/Spell"

class ChainStab extends Spell
  name: "chain stab"
  stat: @stat = "special"
  @element = ChainStab::element = Spell::Element.physical
  @cost = ChainStab::cost = 10
  @restrictions =
    "Rogue": 3

  @canChoose = (caster) -> caster.profession.lastComboSkill in ['opening strike', 'chain stab', 'backstab']

  calcDamage: ->
    minStat = (@caster.calc.stats ['str', 'dex']) * 0.4
    maxStat = (@caster.calc.stats ['str', 'dex']) * 0.6
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

module.exports = exports = ChainStab
