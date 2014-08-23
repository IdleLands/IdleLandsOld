
Spell = require "../../../base/Spell"

class SweepingGeneralization extends Spell
  name: "sweeping generalization"
  @element = SweepingGeneralization::element = Spell::Element.physical
  @cost = SweepingGeneralization::cost = 350
  @restrictions =
    "Generalist": 5

  calcDamage: ->
    minStat = (@caster.calc.stats ['str', 'dex'])/4
    maxStat = (@caster.calc.stats ['str', 'dex'])/2
    super() + @minMax minStat, maxStat

  determineTargets: ->
    @targetAllEnemies()

  cast: (player) ->
    damage = @calcDamage()
    message = "#{@caster.name} cast #{@name} and #{player.name} took %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = SweepingGeneralization
