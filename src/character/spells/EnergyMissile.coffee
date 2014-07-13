
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
    chance.integer min: 1, max: (@caster.calc.stat 'int')/10

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} for #{damage} damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, Spell::Type.magical, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = EnergyMissile