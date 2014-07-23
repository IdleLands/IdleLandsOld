
Spell = require "../base/Spell"
chance = new (require "chance")()
_ = {}
_.str = require "underscore.string"

class Ice extends Spell
  name: "ice"
  @element = Ice::element = Spell::Element.ice
  @cost = Ice::cost = 100
  @restrictions =
    "Mage": 4

  cantAct: -> 1

  cantActMessages: -> "%player is frozen solid"

  calcDuration: -> super()+1

  calcDamage: ->
    chance.integer min: 1, max: Math.max (@caster.calc.stat 'int')/6,(@caster.calc.stat 'int')/4

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} for #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      "self.turn.end": ->

module.exports = exports = Ice