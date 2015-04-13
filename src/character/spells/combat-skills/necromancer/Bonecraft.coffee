
Spell = require "../../../base/Spell"

class Bonecraft extends Spell
  name: "bonecraft"
  @element = Bonecraft::element = Spell::Element.heal
  @tiers = Bonecraft::tiers = [
    `/**
      * This spell revives a dead enemy to the casters side.
      *
      * @name bonecraft
      * @requirement {class} Necromancer
      * @requirement {mp} 0.3*maxMp
      * @requirement {level} 85
      * @element heal
      * @targets {enemy} 1
      * @effect resurrect at 25% hp
      * @category Necromancer
      * @package Spells
    */`
    {name: "bonecraft", spellPower: 1, cost: ((caster) -> Math.round caster.mp.maximum * 0.3), class: "Necromancer", level: 85, collectibles: ["Necronomicon"]}
  ]

  @canChoose = (caster) ->
    Spell.areAnyEnemiesDead caster

  determineTargets: ->
    @targetSomeEnemies includeDead: yes, includeLiving: no

  calcDamage: ->
    super() + (0.25 * @spellPower)

  cast: (player) ->
    damage = @calcDamage()
    damage = parseInt player.hp.maximum*damage
    damage = 1 if damage < 1
    message = "%casterName cast %spellName at %targetName and revived %himher to %damage HP -- but on %casterName's side!"
    @doDamageTo player, -damage, message

    player.party?.playerLeave player, yes
    @caster.party.recruit [player]

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Bonecraft
