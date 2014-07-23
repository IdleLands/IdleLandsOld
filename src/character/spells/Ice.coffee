
Spell = require "../base/Spell"
MessageCreator = require "../../system/MessageCreator"
chance = new (require "chance")()
_ = {}
_.str = require "underscore.string"

class Ice extends Spell
  name: "ice"
  @element = Ice::element = Spell::Element.ice
  @cost = Ice::cost = 100
  @restrictions =
    "Mage": 4

  cantAct: -> if chance.bool({likelihood:25}) then 1 else 0

  cantActMessages: -> "%player is currently frostbitten"

  calcDuration: -> super()+1

  calcDamage: ->
    chance.integer min: 1, max: Math.max (@caster.calc.stat 'int')/6,(@caster.calc.stat 'int')/4

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} for #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message

  uncast: (player) ->
    message = "#{player.name} is no longer frostbitten by #{@name}."
    @game.broadcast MessageCreator.genericMessage message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "self.turn.end": ->

module.exports = exports = Ice