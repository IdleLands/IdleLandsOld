
Spell = require "../../../base/Spell"

class FlipTheBit extends Spell
  name: "flip the bit"
  @element = FlipTheBit::element = Spell::Element.physical
  @stat = FlipTheBit::stat = "special"
  @tiers = FlipTheBit::tiers = [
    `/**
      * This spell flips an enemies HP with their MP
      *
      * @name flip the bit
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 50%
      * @requirement {level} 30
      * @element physical
      * @targets {enemy} 1
      * @category Bitomancer
      * @package Spells
    */`
    {name: "flip the bit", spellPower: 1, cost: ((caster) -> Math.floor(caster.special.maximum/2)), class: "Bitomancer", level: 30}
  ]

  determineTargets: ->
    @targetSomeEnemies size: 1

  cast: (player) ->
    storedHp = player.hp.getValue()
    player.hp.set player.mp.getValue()
    player.mp.set storedHp
    message = "%casterName uses %spellName on %targetName. %targetName's HP and MP are switched!"
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = FlipTheBit