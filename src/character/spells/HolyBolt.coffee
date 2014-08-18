
Spell = require "../base/Spell"

class HolyBolt extends Spell
  name: "holy bolt"
  @element = HolyBolt::element = Spell::Element.holy
  @cost = HolyBolt::cost = 125
  @restrictions =
    "Cleric": 5

  calcDamage: ->
    minStat = (@caster.calc.stat 'wis')/4
    maxStat = @caster.calc.stat 'wis'
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} for #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = HolyBolt
