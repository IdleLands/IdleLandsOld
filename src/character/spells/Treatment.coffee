
Spell = require "../base/Spell"

MessageCreator = require "../../system/MessageCreator"
chance = new (require "chance")()

class Treatment extends Spell
  name: "treatment"
  @element = Treatment::element = Spell::Element.heal & Spell::Element.buff
  @cost = Treatment::cost = 1
  @restrictions =
    "Generalist": 3

  calcDuration: -> 3

  determineTargets: ->
    @targetFriendly()

  calcDamage: (player) ->
    Math.floor (player.hp.maximum * 0.15)

  tick: (player) ->
    restored = @calcDamage player
    message = "#{@caster.name}'s #{@name} restored #{restored} HP for #{player.name}!"
    @caster.party.currentBattle.takeHp @caster, player, -restored, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      "self.turn.end": @tick

module.exports = exports = Treatment