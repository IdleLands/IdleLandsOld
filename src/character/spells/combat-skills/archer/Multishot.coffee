
Spell = require "../../../base/Spell"

class Multishot extends Spell
  name: "multishot"
  @element = Multishot::element = Spell::Element.physical
  @stat = Multishot::stat = "special"
  @tiers = Multishot::tiers = [
    `/**
      * This spell fires twice, possibly at multiple different targets.
      *
      * @name double shot
      * @requirement {class} Archer
      * @requirement {Focus} 20
      * @requirement {level} 10
      * @element physical
      * @targets {enemy} 1-2 (This spell will fail subsequent hits if all valid targets are dead.)
      * @minDamage [dex*0.2]
      * @maxDamage [dex*0.3]
      * @category Archer
      * @package Spells
    */`
    {name: "double shot", spellPower: 1, cost: 20, class: "Archer", level: 10}
    `/**
      * This spell fires thrice, possibly at multiple different targets.
      *
      * @name triple shot
      * @requirement {class} Archer
      * @requirement {Focus} 25
      * @requirement {level} 30
      * @element physical
      * @targets {enemy} 1-3 (This spell will fail subsequent hits if all valid targets are dead.)
      * @minDamage [dex*0.2*2]
      * @maxDamage [dex*0.3*2]
      * @category Archer
      * @package Spells
    */`
    {name: "triple shot", spellPower: 2, cost: 25, class: "Archer", level: 30}
    `/**
      * This spell fires four times, possibly at multiple different targets.
      *
      * @name quadruple shot
      * @requirement {class} Archer
      * @requirement {Focus} 30
      * @requirement {level} 50
      * @element physical
      * @targets {enemy} 1-4 (This spell will fail subsequent hits if all valid targets are dead.)
      * @minDamage [dex*0.2*3]
      * @maxDamage [dex*0.3*3]
      * @category Archer
      * @package Spells
    */`
    {name: "quadruple shot", spellPower: 3, cost: 30, class: "Archer", level: 50}
  ]

  determineTargets: ->
    # 1 spellPower = 1 additional target
    @targetSomeEnemies size: (2 + @spellPower - 1), guaranteeSize: yes

  calcDamage: ->
    # 1 spellPower = 20% base damage
    minStat = (@caster.calc.stat 'dex')*0.2*(0.2*@spellPower+0.8)
    maxStat = (@caster.calc.stat 'dex')*0.3*(0.2*@spellPower+0.8)
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    if player.hp.atMin()
      message = "%targetName is no longer a valid target for %spellName!"
      @broadcast player, message
      return

    message = "%casterName's %spellName hits %targetName for %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Multishot