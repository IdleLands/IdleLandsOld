
Spell = require "../../../base/Spell"

class HolyBolt extends Spell
  name: "holy bolt"
  @element = HolyBolt::element = Spell::Element.holy
  @tiers = HolyBolt::tiers = [
    `/**
      * This is a basic damaging spell.
      *
      * @name holy bolt
      * @requirement {class} Cleric
      * @requirement {mp} 125
      * @requirement {level} 5
      * @minDamage [wis/4]
      * @maxDamage [wis]
      * @category Cleric
      * @package Spells
    */`
    {name: "holy bolt", spellPower: 1, cost: 125, class: "Cleric", level: 5}
    `/**
      * This is a basic damaging spell.
      *
      * @name divine bolt
      * @requirement {class} Cleric
      * @requirement {mp} 250
      * @requirement {level} 30
      * @minDamage [wis/4]*2
      * @maxDamage [wis]*2
      * @category Cleric
      * @package Spells
    */`
    {name: "divine bolt", spellPower: 2, cost: 250, class: "Cleric", level: 30}
    `/**
      * This is a basic damaging spell.
      *
      * @name celestial bolt
      * @requirement {class} Cleric
      * @requirement {mp} 500
      * @requirement {level} 55
      * @minDamage [wis/4]*4
      * @maxDamage [wis]*4
      * @category Cleric
      * @package Spells
    */`
    {name: "celestial bolt", spellPower: 4, cost: 500, class: "Cleric", level: 55}
  ]

  calcDamage: ->
    minStat = @spellPower*(@caster.calc.stat 'wis')/4
    maxStat = @spellPower*@caster.calc.stat 'wis'
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName cast %spellName at %targetName for %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = HolyBolt
