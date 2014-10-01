
Spell = require "../../../base/Spell"
SandwichBuff = require "./SandwichBuff.coffee"
Chance = require "chance"
chance = new Chance()

class DayOldBread extends Spell
  name: "Day-Old Bread"
  @element = DayOldBread::element = Spell::Element.physical
  @cost = DayOldBread::cost = 50
  @restrictions =
    "SandwichArtist": 5

  cantAct: -> 1

  cantActMessages: -> "After eating day-old bread, %player struggles to stand!"

  calcDuration: -> super()+1

  calcDamage: ->
    minStat = (@caster.calc.stat 'dex')/8
    maxStat = (@caster.calc.stat 'dex')/6
    super() + @minMax minStat, maxStat

  determineTargets: ->
    @targetSomeEnemies size: chance.integer({min: 1, max: 2})

  cast: (player) ->
    buff = @game.spellManager.modifySpell new SandwichBuff @game, @caster
    buff.affect player
    buff.name = "day-old #{buff.name}"
    this.name = buff.name
    damage = @calcDamage()
    message = "%casterName served %targetName a %spellName. %targetName falls over and loses %damage HP!"
    @doDamageTo player, damage, message

  tick: (player) ->

  uncast: (player) ->
    message = "%targetName has recovered from eating %casterName's %spellName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = DayOldBread