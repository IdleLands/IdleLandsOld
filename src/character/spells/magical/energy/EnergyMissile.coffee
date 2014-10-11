
Spell = require "../../../base/Spell"

class EnergyMissile extends Spell
  name: "energy missile"
  @element = EnergyMissile::element = Spell::Element.energy
  @tiers = EnergyMissile::tiers = [
    {name: "energy missile", spellPower: 1, cost: 150, class: "Mage", level: 1}
    {name: "energy blast", spellPower: 2, cost: 450, class: "Mage", level: 26}
    {name: "astral flare", spellPower: 4, cost: 2400, class: "Mage", level: 51}
  ]

  calcDamage: ->
    minStat = @spellPower*(@caster.calc.stat 'int')/4
    maxStat = @spellPower*@caster.calc.stat 'int'
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName cast %spellName at %targetName for %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = EnergyMissile
