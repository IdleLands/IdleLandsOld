
Spell = require "../../../base/Spell"
_ = require "underscore"

class FoodFight extends Spell
  name: "food fight"
  @element = FoodFight::element = Spell::Element.physical
  @tiers = FoodFight::tiers = [
    ###*
      * This skill does some damage. It targets 2-10 people.
      *
      * @name food fight
      * @requirement {class} SandwichArtist
      * @requirement {mp} 400
      * @requirement {level} 15
      * @minDamage [dex/6]
      * @maxDamage [dex/4]
      * @category SandwichArtist
      * @package Spells
    ###
    {name: "food fight", spellPower: 1, cost: 400, class: "SandwichArtist", level: 15}
  ]

  calcDuration: (player) -> super()+3
  
  calcDamage: ->
    minStat = (@caster.calc.stat 'dex')/6
    maxStat = (@caster.calc.stat 'dex')/4
    super() + @minMax minStat, maxStat

  determineTargets: -> @targetSome size: @chance.integer({min: 2, max: 10})

  cast: (player) ->
    message = "%targetName is caught in %casterName's %spellName!"
    @broadcast player, message

  tick: (player) ->
    ingredientList = @game.componentDatabase.ingredientStats
    ingredient = _.sample ingredientList['veg']
    @name = ingredient.name
    if @chance.bool({likelihood: 40})
      damage = @calcDamage()
      message = "%targetName is hit by %spellName for %damage damage!"
      @doDamageTo player, damage, message
    else if @chance.bool({likelihood: 40})
      damage = @calcDamage()/2
      message = "%targetName narrowly avoided %spellName."
      @broadcast player, message

  uncast: (player) ->
    @name = "Food Fight"
    message = "%targetName escaped %casterName's \"%spellName.\""
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = FoodFight