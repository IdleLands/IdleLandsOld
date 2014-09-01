
Spell = require "../../../base/Spell"

class FinishingBlow extends Spell
  name: "finishing blow"
  stat: @stat = "special"
  @element = FinishingBlow::element = Spell::Element.physical
  @cost = FinishingBlow::cost = 30
  @restrictions =
    "Rogue": 38

  @canChoose = (caster) -> caster.profession.lastComboSkill in ['wombo combo', 'savage stab', 'heartbleed']

  calcDamage: ->
    minStat = (@caster.calc.stats ['str', 'dex']) * 3
    maxStat = (@caster.calc.stats ['str', 'dex']) * 3.5
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

module.exports = exports = FinishingBlow