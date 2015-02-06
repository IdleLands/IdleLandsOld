
Spell = require "../../../base/Spell"

class DrunkenFrenzy extends Spell
  name: "drunken frenzy"
  @element = DrunkenFrenzy::element = Spell::Element.physical

  determineTargets: ->
    @targetSomeEnemies size: 1

  calcDamage: ->
    baseDamage = (@caster.calc.stat 'str')*(1+(99-@caster.special.getValue())/100)
    minStat = baseDamage*0.8
    maxStat = baseDamage*1.25
    super() + @minMax minStat, maxStat

  cast: (player) ->
    return if @suppressed
    damage = @calcDamage()
    message = "%casterName assaults %targetName in a %spellName for %damage damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = DrunkenFrenzy