
Spell = require "../../../base/Spell"

class TripleFire extends Spell
  name: "triple fire"
  @element = TripleFire::element = Spell::Element.fire
  @tiers = TripleFire::tiers = [
    {name: "double fire", spellPower: 1, cost: 350, class: "Mage", level: 10}
    {name: "triple fire", spellPower: 2, cost: 650, class: "Mage", level: 30}
    {name: "quadruple fire", spellPower: 3, cost: 900, class: "Mage", level: 50}
  ]

  determineTargets: ->
    # 1 spellPower = 1 additional target
    @targetSomeEnemies size: (2 + @spellPower - 1), guaranteeSize: yes

  calcDamage: ->
    # 1 spellPower = 20% base damage
    minStat = (@caster.calc.stat 'int')*0.2*(0.2*@spellPower+0.8)
    maxStat = (@caster.calc.stat 'int')*0.4*(0.2*@spellPower+0.8)
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    if player.hp.atMin()
      message = "%targetName is no longer a valid target for %spellName!"
      @broadcast player, message
      return

    message = "%casterName cast %spellName at %targetName for %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = TripleFire