
Spell = require "../../../base/Spell"

class Deathtouch extends Spell
  @name = Deathtouch::name = "deathtouch"
  @element = Deathtouch::element = Spell::Element.holy | Spell::Element.debuff | Spell::Element.physical
  @tiers = Deathtouch::tiers = [
    `/**
     * This spell does a minor amount of damage, and leeches it back to the caster as HP.
     *
     * @name poisontouch
     * @requirement {class} Necromancer
     * @requirement {mp} 500
     * @requirement {level} 15
     * @element holy, debuff, physical
     * @targets {enemy} 1
     * @effect poison
     * @category Necromancer
     * @package Spells
     */`
    {name: "stuntouch", spellPower: 1, cost: 500,     class: "Necromancer", level: 15}
    `/**
     * This spell does a minor amount of damage, and leeches it back to the caster as HP.
     *
     * @name poisontouch
     * @requirement {class} Necromancer
     * @requirement {mp} 1500
     * @requirement {level} 35
     * @element holy, debuff, physical
     * @targets {enemy} 1
     * @effect poison
     * @effect stun
     * @category Necromancer
     * @package Spells
     */`
    {name: "stuntouch",   spellPower: 1, cost: 1500,    class: "Necromancer", level: 35}
    `/**
     * This spell does a minor amount of damage, and leeches it back to the caster as HP.
     *
     * @name venomtouch
     * @requirement {class} Necromancer
     * @requirement {mp} 3500
     * @requirement {level} 55
     * @element holy, debuff, physical
     * @targets {enemy} 1
     * @effect poison
     * @effect stun
     * @effect venom
     * @category Necromancer
     * @package Spells
     */`
    {name: "venomtouch",  spellPower: 1, cost: 3500,    class: "Necromancer", level: 55}
    `/**
     * This spell does a minor amount of damage, and leeches it back to the caster as HP.
     *
     * @name deathtouch
     * @requirement {class} Necromancer
     * @requirement {mp} 10000
     * @requirement {level} 15
     * @element holy, debuff, physical
     * @targets {enemy} 1
     * @minDamage target.maximumHp * 0.25
     * @maxDamage target.maximumHp * 0.5
     * @effect poison
     * @effect stun
     * @effect venom
     * @category Necromancer
     * @package Spells
     */`
    {name: "deathtouch",  spellPower: 1, cost: 10000,   class: "Necromancer", level: 85, collectibles: ["Forbidden Cleric's Text"]}
  ]

  calcDamage: (target) ->
    console.log @tierName
    return 0 if @tierName isnt "deathtouch"
    minStat = target.hp.maximum * 0.25
    maxStat = target.hp.maximum * 0.5
    super() + @spellPower * @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage player
    message = "%casterName cast %spellName at %targetName#{if damage > 0 then ' for %damage damage' else ''}!"

    effects = []
    effects.push 'Poison' if @caster.level >= 15
    effects.push 'Prone'  if @caster.level >= 35
    effects.push 'Venom'  if @caster.level >= 55

    @caster.party?.currentBattle?.doBattleEffects effects, @caster, player

    if @tierName is "deathtouch"
      @doDamageTo player, damage, message
    else
      @broadcast player, message

  constructor: (@game, @caster, forced) ->
    super @game, @caster, forced
    @bindings =
      doSpellCast: @cast

module.exports = exports = Deathtouch
