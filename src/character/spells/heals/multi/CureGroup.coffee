
Spell = require "../../../base/Spell"
_ = require "lodash"

class CureGroup extends Spell
  name: "cure group"
  @element = CureGroup::element = Spell::Element.heal
  @tiers = CureGroup::tiers = [
    `/**
      * This spell cures your whole group.
      *
      * @name cure group
      * @requirement {class} Cleric
      * @requirement {mp} [partyMembers*50]
      * @requirement {level} 15
      * @element heal
      * @targets {ally} all
      * @minDamage [wis/5]
      * @maxDamage [wis/1.5]
      * @category Cleric
      * @package Spells
    */`
    {name: "cure group", spellPower: 1, cost: ((caster) -> caster.party.players.length * 50), class: "Cleric", level: 15}
  ]

  @canChoose = (caster) ->
    Spell.areAnyPartyMembersBelowMaxHealth caster, 1

  determineTargets: ->
    @targetBelowMaxHealth @targetAllAllies()

  calcDamage: ->
    minStat = (@caster.calc.stat 'wis')/5
    maxStat = (@caster.calc.stat 'wis')/1.5
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName cast %spellName at %targetName and healed %damage HP!"
    @doDamageTo player, -damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = CureGroup
