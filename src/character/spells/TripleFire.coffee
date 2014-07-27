
Spell = require "../base/Spell"
chance = new (require "chance")()
_ = {}
_.str = require "underscore.string"

class TripleFire extends Spell
  name: "triple fire"
  @element = TripleFire::element = Spell::Element.fire
  @cost = TripleFire::cost = 250
  @restrictions =
    "Mage": 10
	
  determineTargets: ->
    @targetEnemy num=3
  
  calcDamage: ->
    chance.integer min: (@caster.calc.stat 'int')*0.4, max: Math.max ((@caster.calc.stat 'int')*0.4)+1,(@caster.calc.stat 'int')*0.7
	
  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} for #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message
	
  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = TripleFire
