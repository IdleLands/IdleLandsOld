
Spell = require "../../../base/Spell"

class Byte extends Spell
  name: "Byte"
  @element = Byte::element = Spell::Element.physical
  @stat = Byte::stat = "special"
  @tiers = Byte::tiers = [
    {name: "Byte", spellPower: 1, cost: 5, class: "Bitomancer", level: 1}
    {name: "Kilobyte", spellPower: 1.4, cost: 20, class: "Bitomancer", level: 17}
    {name: "Megabyte", spellPower: 2, cost: 80, class: "Bitomancer", level: 33}
    {name: "Gigabyte", spellPower: 2.8, cost: 160, class: "Bitomancer", level: 53}
    {name: "Terabyte", spellPower: 4, cost: 320, class: "Bitomancer", level: 76}
  ]

  determineTargets: ->
    @targetSomeEnemies size: 1

  calcDamage: ->
    minStat = (@caster.calc.stat 'int')/8
    maxStat = (@caster.calc.stat 'int')/4
    super() + Math.floor(@spellPower*(@minMax minStat, maxStat))

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName used %spellName on %targetName and stole %damage HP!"
    @doDamageTo player, damage, message
    healing = -(player.calcDamageTaken damage)
    @doDamageTo @caster, healing

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Byte