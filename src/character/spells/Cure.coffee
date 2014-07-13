
Spell = require "../base/Spell"
chance = new (require "chance")()
_ = {}
_.str = require "underscore.string"

class Cure extends Spell
  name: "cure"
  @element = Cure::element = Spell::Element.heal
  @cost = Cure::cost = 50
  @restrictions =
    "Cleric": 1

  determineTargets: ->
    console.log "test1"
    @targetFriendly()

  calcDamage: ->
    chance.integer min: 1, max: Math.max 1,((@caster.calc.stat 'wis')/10)

  cast: (player) ->
    console.log "Test2"
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} at #{player.name} and healed #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, -damage, Spell::Type.magical, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Cure