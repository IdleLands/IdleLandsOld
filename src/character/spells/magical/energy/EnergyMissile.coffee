
Spell = require "../../../base/Spell"

class EnergyMissile extends Spell
  name: "energy missile"
  @element = EnergyMissile::element = Spell::Element.energy
  @tiers = EnergyMissile::tiers = [
    `/**
      * This is a basic damaging spell.
      *
      * @name energy missile
      * @requirement {class} Mage
      * @requirement {mp} 150
      * @requirement {level} 1
      * @element energy
      * @targets {enemy} 1
      * @minDamage [int/4]
      * @maxDamage [int]
      * @category Mage
      * @package Spells
    */`
    {name: "energy missile", spellPower: 1, cost: 150, class: "Mage", level: 1}
    `/**
      * This is a basic damaging spell.
      *
      * @name energy blast
      * @requirement {class} Mage
      * @requirement {mp} 450
      * @requirement {level} 26
      * @element energy
      * @targets {enemy} 1
      * @minDamage [int/4]*2
      * @maxDamage [int]*2
      * @category Mage
      * @package Spells
    */`
    {name: "energy blast", spellPower: 2, cost: 450, class: "Mage", level: 26}
    `/**
      * This is a basic damaging spell.
      *
      * @name astral flare
      * @requirement {class} Mage
      * @requirement {mp} 2400
      * @requirement {level} 51
      * @element energy
      * @targets one enemy
      * @minDamage [int/4]*4
      * @maxDamage [int]*4
      * @category Mage
      * @package Spells
    */`
    {name: "astral flare", spellPower: 4, cost: 2400, class: "Mage", level: 51}
    `/**
     * This is a basic damaging spell.
     *
     * @name energy prod
     * @requirement {class} MagicalMonster
     * @requirement {mp} 250
     * @requirement {level} 1
     * @element energy
     * @targets one enemy
     * @minDamage 1.5*[int/4]
     * @maxDamage 1.5*[int]
     * @category MagicalMonster
     * @package Spells
     */`
    {name: "energy prod", spellPower: 1.5, cost: 250, class: "MagicalMonster", level: 5}
  ]

  calcDamage: ->
    minStat = @spellPower*(@caster.calc.stat 'int')/4
    maxStat = @spellPower*@caster.calc.stat 'int'
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName cast %spellName at %targetName for %damage HP damage!"
    @doDamageTo player, damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = EnergyMissile
