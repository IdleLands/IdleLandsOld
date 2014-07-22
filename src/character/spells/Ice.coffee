
Spell = require "../base/Spell"
chance = new (require "chance")()
_ = {}
_.str = require "underscore.string"

class Ice extends Spell
  name: "ice"
  @element = Ice::element = Spell::Element.ice
  @cost = Ice::cost = 50
  @restrictions =
    "Mage": 5

  calcDamage: ->
    chance.integer min: 1, max: Math.max 1,(@caster.calc.stat 'int')/7

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} for #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Ice