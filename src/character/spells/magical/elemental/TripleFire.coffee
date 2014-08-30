
Spell = require "../../../base/Spell"

class TripleFire extends Spell
  name: "triple fire"
  @element = TripleFire::element = Spell::Element.fire
  @cost = TripleFire::cost = 650
  @restrictions =
    "Mage": 10

  determineTargets: ->
    @targetSomeEnemies size: 3, guaranteeSize: yes

  calcDamage: ->
    minStat = (@caster.calc.stat 'int')*0.3
    maxStat = (@caster.calc.stat 'int')*0.5
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName cast %spellName at %targetName for %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = TripleFire