
Spell = require "../../../base/Spell"

class Cure extends Spell
  name: "cure"
  @element = Cure::element = Spell::Element.heal
  @tiers = Cure::tiers = [
    `/**
      * This spell cures one ally.
      *
      * @name cure
      * @requirement {class} Cleric
      * @requirement {mp} 50
      * @requirement {level} 5
      * @element heal
      * @targets {ally} 1
      * @minDamage 1.5*[wis/4]
      * @maxDamage 1.5*[wis]
      * @category Cleric
      * @package Spells
    */`
    {name: "cure", spellPower: 1.5, cost: 50, class: "Cleric", level: 5}
    `/**
     * This spell cures one ally.
     *
     * @name cure
     * @requirement {class} MagicalMonster
     * @requirement {mp} 100
     * @requirement {level} 10
     * @requirement {collectible} Cleric's Text
     * @element heal
     * @targets {ally} 1
     * @minDamage [wis/4]
     * @maxDamage [wis]
     * @category MagicalMonster
     * @package Spells
     */`
    {name: "cure", spellPower: 1, cost: 100, class: "MagicalMonster", level: 10, collectibles: ["Cleric's Text"]}
  ]

  @canChoose = (caster) ->
    Spell.areAnyPartyMembersBelowMaxHealth caster

  determineTargets: ->
    @targetLowestHp @caster.party.players

  calcDamage: ->
    minStat = (@caster.calc.stat 'wis')/4
    maxStat = @caster.calc.stat 'wis'
    super() + @spellPower * @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName cast %spellName at %targetName and healed %damage HP!"
    @doDamageTo player, -damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Cure
