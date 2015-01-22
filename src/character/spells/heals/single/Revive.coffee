
Spell = require "../../../base/Spell"

class Revive extends Spell
  name: "revive"
  @element = Revive::element = Spell::Element.heal
  @tiers = Revive::tiers = [
    `/**
      * This spell revives a dead ally.
      *
      * @name revive
      * @requirement {class} Cleric
      * @requirement {mp} 500
      * @requirement {level} 30
      * @element heal
      * @targets {ally} 1
      * @effect resurrect at 25% hp
      * @category Cleric
      * @package Spells
    */`
    {name: "revive", spellPower: 1, cost: 500, class: "Cleric", level: 30}
    `/**
      * This spell revives a dead ally.
      *
      * @name resurrect
      * @requirement {class} Cleric
      * @requirement {mp} 2500
      * @requirement {level} 50
      * @element heal
      * @targets {ally} 1
      * @effect resurrect at 50% hp
      * @category Cleric
      * @package Spells
    */`
    {name: "resurrect", spellPower: 2, cost: 2500, class: "Cleric", level: 50}
  ]

  @canChoose = (caster) ->
    Spell.areAnyPartyMembersDead caster

  determineTargets: ->
    @targetSomeAllies includeDead: yes, includeLiving: no

  calcDamage: ->
    super() + (25 * @spellPower)

  cast: (player) ->
    damage = @calcDamage()
    damage = parseInt player.hp.maximum*damage*0.01
    damage = 1 if damage < 1
    message = "%casterName cast %spellName on %targetName and revived %himher to %damage HP!"
    @doDamageTo player, -damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Revive
