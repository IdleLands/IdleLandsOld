
Spell = require "../../../base/Spell"
SandwichBuff = require "./SandwichBuff.coffee"
Chance = require "Chance"
chance = new Chance

class Toasted extends Spell
  name: "Toasted"
  @element = Toasted::element = Spell::Element.fire
  @cost = Toasted::cost = 50
  @restrictions =
    "SandwichArtist": 1
  
  calcDamage: ->
    minStat = (@caster.calc.stat 'dex')/6
    maxStat = (@caster.calc.stat 'dex')/4
    super() + @minMax minStat, maxStat

  determineTargets: ->
    @targetSomeEnemies size: Math.floor(Math.random() + 1.5)

  cast: (player) ->
    buff = @game.spellManager.modifySpell new SandwichBuff @game, @caster
    buff.affect player
    this.name = buff.name
    damage = @calcDamage()
    message = "%casterName made %targetName a %spellName."
    @broadcast player, message
    if player.calculateYesPercent?
      yesno = chance.bool {likelihood: player.calculateYesPercent()}
    else
      yesno = chance.bool {likelihood: 50}
    if yesno
      message = "%targetName wanted the %spellName toasted. %targetName is burned for %damage!"
      @doDamageTo player, damage, message
      this.name = "toasted #{this.name}"
    else
      message = "%targetName didn't want the %spellName toasted."
      @broadcast player, message
    buff.name = this.name

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Toasted