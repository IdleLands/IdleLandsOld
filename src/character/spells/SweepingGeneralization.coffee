
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
    chance.integer min: ((@caster.calc.stats ['str', 'dex'])/4), max: Math.max ((@caster.calc.stats ['str', 'dex'])/4)+1,((@caster.calc.stats ['str', 'dex'])/2)

  determineTargets: ->
    @targetEnemies()

  cast: (player) ->
    damage = @calcDamage()
    #targets = player.party.players
    #_.each targets, (target) =>
    message = "#{@caster.name} cast #{@name} and #{player.name} took #{damage} HP damage!"
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = SweepingGeneralization
