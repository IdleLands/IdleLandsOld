
Spell = require "../base/Spell"
MessageCreator = require "../../system/MessageCreator"

class BoarStrength extends Spell
  name: "boar strength"
  @element = BoarStrength::element = Spell::Element.buff
  @cost = BoarStrength::cost = 300
  @restrictions =
    "Cleric": 4

  calcDuration: -> super.calcDuration()+3

  determineTargets: ->
    @targetFriendly()

  str: (player, baseStr) ->
    baseStr*0.25

  cast: (player) ->
    message = "#{@caster.name} infused #{player.name} with #{@name}!"
    @game.broadcast MessageCreator.genericMessage message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      "self.turn.end": ->

module.exports = exports = BoarStrength