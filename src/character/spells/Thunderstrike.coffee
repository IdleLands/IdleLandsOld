
Spell = require "../base/Spell"
chance = new (require "chance")()
_ = {}
_.str = require "underscore.string"

class Thunderstrike extends Spell
  name: "thunderstrike"
  @element = Thunderstrike::element = Spell::Element.thunder
  @cost = Thunderstrike::cost = 1
  @restrictions =
    "Generalist": 100

  damage = 1

  calcDuration: -> super()+(chance.integer min: 1, max: 3)

  calcDamage: ->
    chance.integer min: (@caster.calc.stat 'int')*0.25*@turns, max: Math.max ((@caster.calc.stat 'int')*0.25*@turns)+1,(@caster.calc.stat 'int')+0.3*(@turns-1)

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name}!"
    @broadcast message


  uncast: (player) ->
    message = "#{player.name} is struck by #{@name} for #{damage}!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message


  tick: (player) ->
    message = "Storm clouds brew above #{player.name}..."
    @broadcast message


  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "self.turn.end": @tick

module.exports = exports = Thunderstrike