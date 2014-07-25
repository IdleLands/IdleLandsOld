
Spell = require "../base/Spell"
chance = new (require "chance")()
_ = {}
_.str = require "underscore.string"

class CureGroup extends Spell
  name: "cure group"
  @element = CureGroup::element = Spell::Element.heal
  @cost = CureGroup::cost = (50 * @caster.party.targetFriendlies().size)
  @restrictions =
    "Cleric": 10

  calcDamage: ->
    chance.integer min: 1, max: Math.max ((@caster.calc.stat 'wis')/4),((@caster.calc.stat 'wis')/2)

  cast: (player) ->
    damage = @calcDamage()
    targets = @caster.party.targetFriendlies()
    _.each targets, (target) =>
      message = "#{@caster.name} cast #{@name} at #{target.name} and healed #{damage} HP!"
      @caster.party.currentBattle.takeHp @caster, target, -damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = CureGroup