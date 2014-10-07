
Spell = require "../../../base/Spell"

class WomboCombo extends Spell
  name: "wombo combo"
  stat: @stat = "special"
  @element = WomboCombo::element = Spell::Element.physical
  @tiers = WomboCombo::tiers = [
    {name: "wombo combo", spellPower: 1, cost: 25, class: "Rogue", level: 25}
  ]

  @canChoose = (caster) -> caster.profession.lastComboSkill in ['chain stab', 'heartbleed']

  calcDamage: ->
    minStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 0.45
    maxStat = ((@caster.calc.stats ['str', 'dex']) / 2) * 0.5
    super() + @minMax minStat, maxStat

  cast: (player) ->
    @caster.profession.updateCombo @

    for i in [1..3]
      return if player.hp.atMin()

      damage = @calcDamage()
      message = "%casterName used %spellName on %targetName and dealt %damage HP damage!"
      @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = WomboCombo
