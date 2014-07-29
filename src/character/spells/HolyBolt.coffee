
Spell = require "../base/Spell"

class HolyBolt extends Spell
  name: "holy bolt"
  @element = HolyBolt::element = Spell::Element.holy
  @cost = HolyBolt::cost = 75
  @restrictions =
    "Cleric": 5

  calcDamage: ->
    @chance.integer min: (@caster.calc.stat 'wis')/4, max: Math.max ((@caster.calc.stat 'wis')/4)+1,(@caster.calc.stat 'wis')

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} for #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = HolyBolt
