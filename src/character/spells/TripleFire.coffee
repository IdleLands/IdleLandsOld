
Spell = require "../base/Spell"

class TripleFire extends Spell
  name: "triple fire"
  @element = TripleFire::element = Spell::Element.fire
  @cost = TripleFire::cost = 650
  @restrictions =
    "Mage": 10

  determineTargets: ->
    @targetEnemy no, 3

  calcDamage: ->
    minStat = (@caster.calc.stat 'int')*0.4
    maxStat = (@caster.calc.stat 'int')*0.75
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} for %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = TripleFire