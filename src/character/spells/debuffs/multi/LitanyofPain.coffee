
Spell = require "../../../base/Spell"

class LitanyOfPain extends Spell
  name: "Litany of Pain"
  @element = LitanyOfPain::element = Spell::Element.energy
  @cost = LitanyOfPain::cost = 300
  @restrictions =
    "Bard": 15

  calcDuration: -> super()+3
  
  calcDamage: ->
    minInt = (@caster.calc.stat 'int')/5
    maxInt = (@caster.calc.stat 'int')/2
    super() + @minMax minInt, maxInt

  determineTargets: ->
    @targetAllEnemies()

  init: ->
    message = "%casterName begins playing \"%spellName!\""
    @broadcast @caster, message

  tick: (player) ->
    damage = @calcDamage()
    message = "%targetName is damaged by %casterName's \"%spellName\" for %damage HP damage"
    @doDamageTo player, damage, message

  uncast: (player) ->
    message = "%targetName is no longer under the effects of \"%spellName.\""
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellInit: @init
      doSpellUncast: @uncast
      "combat.round.start": @tick

module.exports = exports = LitanyOfPain