
Spell = require "../../../base/Spell"

class Siphon extends Spell
  @name = Siphon::name = "siphon"
  @element = Siphon::element = Spell::Element.energy | Spell::Element.holy | Spell::Element.debuff | Spell::Element.physical
  @tiers = Siphon::tiers = [
    `/**
     * This spell does a minor amount of damage, and leeches it back to the caster as HP.
     *
     * @name siphon
     * @requirement {class} Necromancer
     * @requirement {mp} 100
     * @requirement {level} 1
     * @element energy, holy, debuff, physical
     * @targets {enemy} 1
     * @minDamage [wis/8]
     * @maxDamage [wis/4]
     * @category Necromancer
     * @package Spells
     */`
    {name: "siphon", spellPower: 1, cost: 100, class: "Necromancer", level: 1}
    `/**
     * This spell does a minor amount of damage, and leeches it back to the caster as HP. It also leaves a minor debuff.
     *
     * @name drain
     * @requirement {class} Necromancer
     * @requirement {mp} 100
     * @requirement {level} 15
     * @element energy, holy, debuff, physical
     * @targets {enemy} 1
     * @minDamage 1.25*[wis/8]
     * @maxDamage 1.25*[wis/4]
     * @effect -5% STR
     * @effect vampirism
     * @category Necromancer
     * @package Spells
     */`
    {name: "drain", spellPower: 1.25, cost: 300, class: "Necromancer", level: 15}
    `/**
     * This spell does a moderate amount of damage, and leeches it back to the caster as HP. It also leaves a moderate debuff.
     *
     * @name deteriorate
     * @requirement {class} Necromancer
     * @requirement {mp} (maxHp-currentHp)/5
     * @requirement {level} 35
     * @element energy, holy, debuff, physical
     * @targets {enemy} 1
     * @minDamage 1.5*[wis/8]
     * @maxDamage 1.5*[wis/4]
     * @effect -5% STR
     * @effect -5% HP
     * @effect vampirism
     * @category Necromancer
     * @package Spells
     */`
    {name: "deteriorate", spellPower: 1.5, cost: ((caster) -> Math.round caster.hp.maximum - caster.hp.getValue()/5), class: "Necromancer", level: 35}
    `/**
     * This spell does a moderate amount of damage, and leeches it back to the caster as HP. It also leaves a major debuff.
     *
     * @name wither
     * @requirement {class} Necromancer
     * @requirement {mp} (maxHp-currentHp)/2
     * @requirement {level} 75
     * @element energy, holy, debuff, physical
     * @targets {enemy} 1
     * @minDamage 1.5*[wis/8]
     * @maxDamage 1.5*[wis/4]
     * @effect -5% STR
     * @effect -5% DEX
     * @effect -5% CON
     * @effect -5% AGI
     * @effect -5% WIS
     * @effect -5% INT
     * @effect -5% HP
     * @effect vampirism
     * @category Necromancer
     * @package Spells
     */`
    {name: "wither", spellPower: 1.75, cost: ((caster) -> Math.round caster.hp.maximum - caster.hp.getValue()/2), class: "Necromancer", level: 75}
  ]

  hpPercent: ->
    base = 0
    if @caster.level.getValue() >= 35 then base -= 15
    base

  strPercent: ->
    base = 0
    if @caster.level.getValue() >= 75 then base -= 5
    base

  dexPercent: ->
    base = 0
    if @caster.level.getValue() >= 75 then base -= 5
    base

  conPercent: ->
    base = 0
    if @caster.level.getValue() >= 75 then base -= 5
    base

  agiPercent: ->
    base = 0
    if @caster.level.getValue() >= 75 then base -= 5
    base

  wisPercent: ->
    base = 0
    if @caster.level.getValue() >= 75 then base -= 5
    base

  intPercent: ->
    base = 0
    if @caster.level.getValue() >= 75 then base -= 5
    base

  calcDuration: ->
    base = 0
    if @caster.level.getValue() >= 15 then base += 2
    if @caster.level.getValue() >= 35 then base += 1
    if @caster.level.getValue() >= 75 then base += 1
    base

  calcDamage: ->
    minStat = (@caster.calc.stat 'wis')/8
    maxStat = (@caster.calc.stat 'wis')/4
    super() + @spellPower * @minMax minStat, maxStat

  calcVampirismDamage: (target) ->
    Math.round target.hp.getValue() * 0.02

  tick: (player) ->
    damage = @calcVampirismDamage player
    message = "%targetName is still affected by %spellName and lost %damage HP#{if @caster.hp.atMin() then '' else ' to %casterName'}!"
    @doDamageTo player, damage, message
    @doDamageTo @caster, -damage, '' if not @caster.hp.atMin()

  cast: (player) ->
    damage = @calcDamage @caster
    message = "%casterName cast %spellName at %targetName for %damage damage!"
    @doDamageTo player, damage, message

  uncast: (player) ->
    message = "%targetName has recovered from %spellName."
    @broadcast player, message

  constructor: (@game, @caster, forced) ->
    super @game, @caster, forced
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = Siphon
