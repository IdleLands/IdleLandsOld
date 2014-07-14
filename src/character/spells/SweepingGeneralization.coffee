
Spell = require "../base/Spell"
chance = new (require "chance")()
_ = require "underscore"

class SweepingGeneralization extends Spell
  name: "sweeping generalization"
  @element = SweepingGeneralization::element = Spell::Element.normal
  @cost = SweepingGeneralization::cost = 1
  @restrictions =
    "Generalist": 1

  calcDamage: ->
    chance.integer min: 1, max: Math.max 1,((@caster.calc.stat 'str')/5)

  cast: (player) ->
    damage = @calcDamage()
    targets = player.party.players
    _.each targets, (target) =>
      message = "#{@caster.name} cast #{@name} and #{target.name} took #{damage} HP damage!"
      @caster.party.currentBattle.takeHp @caster, target, damage, Spell::Type.physical, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = SweepingGeneralization