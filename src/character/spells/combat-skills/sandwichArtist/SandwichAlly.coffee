
Spell = require "../../../base/Spell"
SandwichBuff = require "./SandwichBuff.coffee"
Cookie = require "./Cookie.coffee"

class SandwichAlly extends Spell
  name: "sandwich ally"
  @element = SandwichAlly::element = Spell::Element.physical
  @tiers = SandwichAlly::tiers = [
    `/**
      * This skill feeds an ally. As for what that means, that depends on the sandwich made.
      *
      * @name sandwich ally
      * @requirement {class} SandwichArtist
      * @requirement {mp} 200
      * @requirement {level} 10
      * @element physical
      * @targets {ally} 1
      * @minHeal dex/5
      * @minHeal dex/1.5
      * @category SandwichArtist
      * @package Spells
    */`
    {name: "Sandwich Ally", spellPower: 1, cost: 200, class: "SandwichArtist", level: 10}
  ]

# Cure group level healing
  calcDamage: ->
    minStat = (@caster.calc.stat 'dex')/5
    maxStat = (@caster.calc.stat 'dex')/1.5
    super() + @minMax minStat, maxStat

  determineTargets: ->
    @targetSomeAllies size: @chance.integer({min: 1, max: 2})

  cast: (player) ->
    buff = @game.spellManager.modifySpell new SandwichBuff @game, @caster
    buff.prepareCast player
    @name = buff.name
    damage = @calcDamage()
    message = "%casterName made %targetName a %spellName and healed %damage HP!"
    @doDamageTo player, -damage, message
    if player isnt @caster
      if @chance.integer({min: 1, max: 10}) < 10
        # Rate the sandwich; moderate chance of rating a 5, >50% chance of not doing so
        rating = @chance.integer({min: 1, max: 7})
        if rating < 5
          message = "%targetName rated the %spellName a #{rating}. %casterName confiscates his cookie!"
          @broadcast player, message
          cookie = @game.spellManager.modifySpell new Cookie @game, @caster
          cookie.prepareCast @caster
        else
          message = "%targetName rated the %spellName a 5, and gets a free cookie!"
          @broadcast player, message
          cookie = @game.spellManager.modifySpell new Cookie @game, @caster
          cookie.prepareCast player

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = SandwichAlly