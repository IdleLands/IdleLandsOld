
Spell = require "../../../base/Spell"

class Bit extends Spell
  name: "Bit"
  @element = Bit::element = Spell::Element.physical
  @stat = Bit::stat = "special"
  @tiers = Bit::tiers = [
    {name: "Bit", spellPower: 1, cost: 5, class: "Bitomancer", level: 1}
    {name: "Kilobit", spellPower: 1.4, cost: 20, class: "Bitomancer", level: 17}
    {name: "Megabit", spellPower: 2, cost: 80, class: "Bitomancer", level: 33}
    {name: "Gigabit", spellPower: 2.8, cost: 160, class: "Bitomancer", level: 53}
    {name: "Terabit", spellPower: 4, cost: 320, class: "Bitomancer", level: 76}
  ]

  determineTargets: ->
    @targetSomeEnemies size: 1

  calcDamage: ->
    minStat = (@caster.calc.stat 'int')/6
    maxStat = (@caster.calc.stat 'int')/2
    super() + Math.floor(@spellPower*(@minMax minStat, maxStat))

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName used %spellName on %targetName and dealt %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Bit