
Spell = require "../../../base/Spell"

class Byte extends Spell
  name: "byte"
  @element = Byte::element = Spell::Element.physical
  @stat = Byte::stat = "special"
  @tiers = Byte::tiers = [
    `/**
      * This spell leeches some health from an enemy.
      *
      * @name byte
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 5
      * @requirement {level} 1
      * @element physical
      * @minDamage [int/8]
      * @maxDamage [int/4]
      * @category Bitomancer
      * @package Spells
    */`
    {name: "byte", spellPower: 1, cost: 5, class: "Bitomancer", level: 1}
    `/**
      * This spell leeches some health from an enemy.
      *
      * @name kilobyte
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 20
      * @requirement {level} 17
      * @element physical
      * @minDamage [int/8]*1.4
      * @maxDamage [int/4]*1.4
      * @category Bitomancer
      * @package Spells
    */`
    {name: "kilobyte", spellPower: 1.4, cost: 20, class: "Bitomancer", level: 17}
    `/**
      * This spell leeches some health from an enemy.
      *
      * @name megabyte
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 80
      * @requirement {level} 33
      * @element physical
      * @minDamage [int/8]*2
      * @maxDamage [int/4]*2
      * @category Bitomancer
      * @package Spells
    */`
    {name: "megabyte", spellPower: 2, cost: 80, class: "Bitomancer", level: 33}
    `/**
      * This spell leeches some health from an enemy.
      *
      * @name gigabyte
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 160
      * @requirement {level} 53
      * @element physical
      * @minDamage [int/8]*2.8
      * @maxDamage [int/4]*2.8
      * @category Bitomancer
      * @package Spells
    */`
    {name: "gigabyte", spellPower: 2.8, cost: 160, class: "Bitomancer", level: 53}
    `/**
      * This spell leeches some health from an enemy.
      *
      * @name terabyte
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 320
      * @requirement {level} 76
      * @element physical
      * @minDamage [int/8]*4
      * @maxDamage [int/4]*4
      * @category Bitomancer
      * @package Spells
    */`
    {name: "terabyte", spellPower: 4, cost: 320, class: "Bitomancer", level: 76}
  ]

  determineTargets: ->
    @targetSomeEnemies size: 1

  calcDamage: ->
    minStat = (@caster.calc.stat 'int')/8
    maxStat = (@caster.calc.stat 'int')/4
    super() + Math.floor(@spellPower*(@minMax minStat, maxStat))

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName used %spellName on %targetName and stole %damage HP!"
    @doDamageTo player, damage, message
    healing = -(player.calcDamageTaken damage)
    @doDamageTo @caster, healing

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Byte