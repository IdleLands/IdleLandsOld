
Spell = require "../../../base/Spell"

class OpeningStrike extends Spell
  name: "opening strike"
  stat: @stat = "special"
  @element = OpeningStrike::element = Spell::Element.physical
  @cost = OpeningStrike::cost = 10
  @restrictions =
    "Rogue": 1

  @canChoose = (caster) -> caster.profession.lastComboSkillTurn <= 0

  calcDamage: ->
    minStat = (@caster.calc.stats ['str', 'dex']) * 0.5
    maxStat = (@caster.calc.stats ['str', 'dex']) * 0.75
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

module.exports = exports = OpeningStrike