
Spell = require "../base/Spell"

class TripleFire extends Spell
  name: "triple fire"
  @element = TripleFire::element = Spell::Element.fire
  @cost = TripleFire::cost = 250
  @restrictions =
    "Mage": 10

  determineTargets: ->
    @targetEnemy no, 3

  calcDamage: ->
    minDmg = (@caster.calc.stat 'int')*0.4
    maxDmg = (@caster.calc.stat 'int')*0.8
    @chance.integer min: minDmg, max: Math.max (minDmg)+1,maxDmg

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} for #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = TripleFire