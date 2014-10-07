
Spell = require "../../../base/Spell"

class HolyBolt extends Spell
  name: "holy bolt"
  @element = HolyBolt::element = Spell::Element.holy
  @tiers = HolyBolt::tiers = [
    {name: "holy bolt", spellPower: 1, cost: 125, class: "Cleric", level: 5}
    {name: "divine bolt", spellPower: 2, cost: 250, class: "Cleric", level: 30}
    {name: "celestial bolt", spellPower: 4, cost: 500, class: "Cleric", level: 55}
  ]

  calcDamage: ->
    minStat = @spellPower*(@caster.calc.stat 'wis')/4
    maxStat = @spellPower*@caster.calc.stat 'wis'
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName cast %spellName at %targetName for %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = HolyBolt
