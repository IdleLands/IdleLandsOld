
Spell = require "../base/Spell"

class Thunderstrike extends Spell
  name: "thunderstrike"
  @element = Thunderstrike::element = Spell::Element.thunder
  @cost = Thunderstrike::cost = 150
  @restrictions =
    "Mage": 7

  calcDuration: -> super()+(@chance.integer min: 1, max: 3)

  calcDamage: ->
    intDamage = (@caster.calc.stat 'int') * 0.25 * @baseTurns
    maxIntDamage = (@caster.calc.stat 'int') * 0.3 * (@baseTurns-1)
    @chance.integer min: intDamage, max: Math.max intDamage+1,maxIntDamage

  cast: (player) ->
    message = "#{@caster.name} cast #{@name} at #{player.name}!"
    @broadcast message

  uncast: (player) ->
    damage = @calcDamage()
    message = "#{player.name} was struck by #{@caster.name}'s #{@name} for #{damage} HP damage!"
    @caster.party?.currentBattle?.takeHp @caster, player, damage, @determineType(), message

  tick: (player) ->
    message = "Storm clouds brew above #{player.name}..."
    @broadcastBuffMessage message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "self.turn.end": @tick

module.exports = exports = Thunderstrike