
Spell = require "../base/Spell"

class Cure extends Spell
  name: "cure"
  @element = Cure::element = Spell::Element.heal
  @cost = Cure::cost = 50
  @restrictions =
    "Cleric": 5

  determineTargets: ->
    @targetFriendly()

  calcDamage: ->
    @chance.integer min: ((@caster.calc.stat 'wis')/4), max: Math.max (((@caster.calc.stat 'wis')/4)+1),(@caster.calc.stat 'wis')

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} and healed #{damage} HP!"
    @caster.party.currentBattle.takeHp @caster, player, -damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Cure
