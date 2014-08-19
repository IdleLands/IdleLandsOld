
Spell = require "../base/Spell"

class Thunderstrike extends Spell
  name: "thunderstrike"
  @element = Thunderstrike::element = Spell::Element.thunder
  @cost = Thunderstrike::cost = 375
  @restrictions =
    "Mage": 7

  calcDuration: -> super()+(@chance.integer min: 1, max: 3)

  calcDamage: ->
    intDamage = (@caster.calc.stat 'int') * 0.25 * @baseTurns
    maxIntDamage = (@caster.calc.stat 'int') + 0.4 * (@baseTurns-1)
    super() + @minMax intDamage, maxIntDamage

  cast: (player) ->
    message = "#{@caster.name} cast #{@name} at #{player.name}!"
    @broadcast message

  uncast: (player) ->
    return if not @caster.party or not @caster.party.currentBattle
    damage = @calcDamage()
    message = "#{player.name} was struck by #{@caster.name}'s #{@name} for %damage HP damage!"
    @doDamageTo player, damage, message

  tick: (player) ->
    message = "Storm clouds brew above #{player.name}..."
    @broadcast message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = Thunderstrike