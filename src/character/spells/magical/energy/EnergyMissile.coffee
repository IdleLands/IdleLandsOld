
Spell = require "../../../base/Spell"

class EnergyMissile extends Spell
  name: "energy missile"
  @element = EnergyMissile::element = Spell::Element.energy
  @cost = EnergyMissile::cost = 150
  @restrictions =
    "Mage": 1

  calcDamage: ->
    minStat = (@caster.calc.stat 'int')/4
    maxStat = @caster.calc.stat 'int'
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
