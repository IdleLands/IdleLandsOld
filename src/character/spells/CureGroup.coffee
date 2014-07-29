
Spell = require "../base/Spell"

class CureGroup extends Spell
  name: "cure group"
  @element = CureGroup::element = Spell::Element.heal
  @cost = CureGroup::cost = (caster) -> caster.party.players.length * 50

  @restrictions =
    "Cleric": 15

  determineTargets: ->
    @targetParty()

  calcDamage: ->
    @chance.integer min: ((@caster.calc.stat 'wis')/5), max: Math.max (((@caster.calc.stat 'wis')/5)+1),(@caster.calc.stat 'wis')/1.5

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} and healed #{damage} HP!"
    @caster.party.currentBattle.takeHp @caster, player, -damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = CureGroup
