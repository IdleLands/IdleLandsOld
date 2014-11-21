
Spell = require "../../../base/Spell"

class Bit extends Spell
  name: "bit"
  @element = Bit::element = Spell::Element.physical
  @stat = Bit::stat = "special"
  @tiers = Bit::tiers = [
    ###*
      * This spell does some damage to an enemy.
      *
      * @name bit
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 5
      * @requirement {level} 1
      * @minDamage [int/6]
      * @maxDamage [int/2]
      * @category Bitomancer
      * @package Spells
    ###
    {name: "bit", spellPower: 1, cost: 5, class: "Bitomancer", level: 1}
    ###*
      * This spell does some damage to an enemy.
      *
      * @name kilobit
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 20
      * @requirement {level} 17
      * @minDamage [int/6]*1.4
      * @maxDamage [int/2]*1.4
      * @category Bitomancer
      * @package Spells
    ###
    {name: "kilobit", spellPower: 1.4, cost: 20, class: "Bitomancer", level: 17}
    ###*
      * This spell does some damage to an enemy.
      *
      * @name megabit
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 80
      * @requirement {level} 33
      * @minDamage [int/6]*2
      * @maxDamage [int/2]*2
      * @category Bitomancer
      * @package Spells
    ###
    {name: "megabit", spellPower: 2, cost: 80, class: "Bitomancer", level: 33}
    ###*
      * This spell does some damage to an enemy.
      *
      * @name gigabit
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 160
      * @requirement {level} 53
      * @minDamage [int/6]*2.8
      * @maxDamage [int/2]*2.8
      * @category Bitomancer
      * @package Spells
    ###
    {name: "gigabit", spellPower: 2.8, cost: 160, class: "Bitomancer", level: 53}
    ###*
      * This spell does some damage to an enemy.
      *
      * @name terabit
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 320
      * @requirement {level} 76
      * @minDamage [int/6]*4
      * @maxDamage [int/2]*4
      * @category Bitomancer
      * @package Spells
    ###
    {name: "terabit", spellPower: 4, cost: 320, class: "Bitomancer", level: 76}
  ]

  determineTargets: ->
    @targetSomeEnemies size: 1

  calcDamage: ->
    minStat = (@caster.calc.stat 'int')/6
    maxStat = (@caster.calc.stat 'int')/2
    super() + Math.floor(@spellPower*(@minMax minStat, maxStat))

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName used %spellName on %targetName and dealt %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Bit