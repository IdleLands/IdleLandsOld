
Spell = require "../base/Spell"
chance = new (require "chance")()
_ = require "underscore"

class SweepingGeneralization extends Spell
  name: "sweeping generalization"
  @element = SweepingGeneralization::element = Spell::Element.normal
  @cost = SweepingGeneralization::cost = 250
  @restrictions =
    "Generalist": 1

  calcDamage: ->
    chance.integer min: 1, max: Math.max ((@caster.calc.stats ['str', 'dex'])/4),((@caster.calc.stats ['str', 'dex'])/2)

  cast: (player) ->
    damage = @calcDamage()
    targets = player.party.players
    _.each targets, (target) =>
      message = "#{@caster.name} cast #{@name} and #{target.name} took #{damage} HP damage!"
      @caster.party.currentBattle.takeHp @caster, target, damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = SweepingGeneralization