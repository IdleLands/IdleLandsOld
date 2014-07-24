
Spell = require "../base/Spell"
chance = new (require "chance")()
_ = {}
_.str = require "underscore.string"

class EnergyMissile extends Spell
  name: "energy missile"
  @element = EnergyMissile::element = Spell::Element.energy
  @cost = EnergyMissile::cost = 50
  @restrictions =
    "Mage": 1

  calcDamage: ->
    chance.integer min: (@caster.calc.stat 'int')/4, max: Math.max ((@caster.calc.stat 'int')/4)+1,(@caster.calc.stat 'int')

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} for #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = EnergyMissile
