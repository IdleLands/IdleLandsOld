
Spell = require "../../../base/Spell"
SandwichBuff = require "./SandwichBuff.coffee"

class DayOldBread extends Spell
  name: "day-old bread"
  @element = DayOldBread::element = Spell::Element.physical
  @tiers = DayOldBread::tiers = [
    `/**
      * This skill does some damage, and stuns for a turn. It targets 1-2 enemies.
      *
      * @name day-old bread
      * @requirement {class} SandwichArtist
      * @requirement {mp} 50
      * @requirement {level} 5
      * @minDamage [dex/8]
      * @maxDamage [dex/6]
      * @duration 1 round
      * @effect STUN
      * @category SandwichArtist
      * @package Spells
    */`
    {name: "day-old bread", spellPower: 1, cost: 50, class: "SandwichArtist", level: 5}
  ]

  cantAct: -> 1

  cantActMessages: -> "After eating day-old bread, %player struggles to stand!"

  calcDuration: -> super()+1

  calcDamage: ->
    minStat = (@caster.calc.stat 'dex')/8
    maxStat = (@caster.calc.stat 'dex')/6
    super() + @minMax minStat, maxStat

  determineTargets: ->
    @targetSomeEnemies size: @chance.integer({min: 1, max: 2})

  cast: (player) ->
    buff = @game.spellManager.modifySpell new SandwichBuff @game, @caster
    buff.prepareCast player
    buff.name = "day-old #{buff.name}"
    @name = buff.name
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