
Spell = require "../base/Spell"
chance = new (require "chance")()
_ = {}
_.str = require "underscore.string"

class DivineBolt extends Spell
  name: "divine bolt"
  @element = DivineBolt::element = Spell::Element.divine
  @cost = DivineBolt::cost = 50
  @restrictions =
    "Cleric": 1

  calcDamage: ->
    chance.integer min: (@caster.calc.stat 'wis')/4, max: Math.max ((@caster.calc.stat 'wis')/4)+1,(@caster.calc.stat 'wis')

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} called upon his God, Pelor, for assistance. Suddenly #{player.name} is struck from the heavens by a bolt of light for #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = DivineBolt
