
Spell = require "../base/Spell"

MessageCreator = require "../../system/MessageCreator"
chance = new (require "chance")()

class Treatment extends Spell
  name: "treatment"
  @element = Treatment::element = Spell::Element.heal & Spell::Element.buff
  @cost = Treatment::cost = 225
  @restrictions =
    "Generalist": 7

  calcDuration: -> super.calcDuration()+3

  determineTargets: ->
    @targetFriendly()

  calcDamage: (player) ->
    Math.floor (player.hp.maximum * 0.15)

  cast: (player) ->
    message = "#{@caster.name} began treating #{player.name}'s wounds with #{@name}!"
    @game.broadcast MessageCreator.genericMessage message

  tick: (player) ->
    restored = @calcDamage player
    message = "#{@caster.name}'s #{@name} restored #{restored} HP for #{player.name}!"
    @caster.party.currentBattle.takeHp @caster, player, -restored, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      "self.turn.end": @tick
      doSpellCast: @cast

module.exports = exports = Treatment