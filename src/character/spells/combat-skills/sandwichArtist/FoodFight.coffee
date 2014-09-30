
Spell = require "../../../base/Spell"
Prone = require "../effects/Prone.coffee"
_ = require "underscore"
Chance = require "Chance"
chance = new Chance

class FoodFight extends Spell
  name: "Food Fight"
  @element = FoodFight::element = Spell::Element.physical
  @cost = FoodFight::cost = 0
  @restrictions =
    "SandwichArtist": 1

  calcDuration: (player) -> super()+3
  
  calcDamage: ->
    minStat = (@caster.calc.stat 'dex')/6
    maxStat = (@caster.calc.stat 'dex')/4
    super() + @minMax minStat, maxStat

  determineTargets: -> @targetSome size: chance.integer({min: 2, max: 10})

  cast: (player) ->
    message = "%targetName is caught in %casterName's %spellName!"
    @broadcast player, message

  tick: (player) ->
    ingredientList = @game.componentDatabase.ingredientStats
    ingredient = _.sample ingredientList['veg']
    this.name = ingredient.name
    if chance.bool({likelihood: 40})
      damage = @calcDamage()
      message = "%targetName is hit by %spellName for %damage damage!"
      @doDamageTo player, damage, message
    else if chance.bool({likelihood: 40})
      damage = @calcDamage()/2
      message = "%targetName slips on some %spellName and falls down!"
      @broadcast player, message
      prone = @game.spellManager.modifySpell new Prone @game, @caster
      prone.affect player
    else if chance.bool({likelihood: 40})
      damage = @calcDamage()/2
      message = "%targetName narrowly avoided %spellName."
      @broadcast player, message

  uncast: (player) ->
    return if @caster isnt player
    this.name = "Food Fight"
    message = "%targetName is no longer under the effects of \"%spellName.\""
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = FoodFight