
Spell = require "../../../base/Spell"

class Thunderstrike extends Spell
  name: "thunderstrike"
  @element = Thunderstrike::element = Spell::Element.thunder
  @tiers = Thunderstrike::tiers = [
    `/**
      * This spell has a delayed effect on striking, and can hit up to 2 targets, but does more damage the longer it takes.
      *
      * @name thunderstrike
      * @requirement {class} Mage
      * @requirement {mp} 375
      * @requirement {level} 7
      * @element thunder
      * @targets {enemy} 1-2
      * @minDamage [int*0.25*rounds]
      * @maxDamage [int*0.40*rounds-1]
      * @duration [1-3] rounds
      * @category Mage
      * @package Spells
    */`
    {name: "thunderstrike", spellPower: 1, cost: 375, class: "Mage", level: 7}
    `/**
      * This spell has a delayed effect on striking, and can hit up to 3 targets, but does more damage the longer it takes.
      *
      * @name thunderstorm
      * @requirement {class} Mage
      * @requirement {mp} 675
      * @requirement {level} 27
      * @element thunder
      * @targets {enemy} 1-3
      * @minDamage [int*0.25*rounds]
      * @maxDamage [int*0.40*rounds-1]
      * @duration [1-3] rounds
      * @category Mage
      * @package Spells
    */`
    {name: "thundernado", spellPower: 2, cost: 675, class: "Mage", level: 27}
    `/**
      * This spell has a delayed effect on striking, and can hit up to 4 targets, but does more damage the longer it takes.
      *
      * @name thundernado
      * @requirement {class} Mage
      * @requirement {mp} 925
      * @requirement {level} 47
      * @element thunder
      * @targets {enemy} 1-4
      * @minDamage [int*0.25*rounds]
      * @maxDamage [int*0.40*rounds-1]
      * @duration [1-3] rounds
      * @category Mage
      * @package Spells
    */`
    {name: "thunderstorm", spellPower: 3, cost: 925, class: "Mage", level: 47}
  ]

  calcDuration: -> super()+(@chance.integer min: 1, max: 3)

  determineTargets: ->
    @targetSomeEnemies size: @chance.integer({min: 1, max: (1 + @spellPower)}),

  calcDamage: (player) ->
    intDamage = (@caster.calc.stat 'int') * 0.25 * @baseTurns[player.name]
    maxIntDamage = (@caster.calc.stat 'int') + 0.4 * (@baseTurns[player.name]-1)
    super() + @minMax intDamage, maxIntDamage

  cast: (player) ->
    message = "%casterName cast %spellName at %targetName!"
    @broadcast player, message

  uncast: (player) ->
    return if not @caster.party or not @caster.party.currentBattle
    return if player.hp.atMin()
    return if @suppressed
    damage = @calcDamage player
    message = "%targetName was struck by %casterName's %spellName for %damage HP damage!"
    @doDamageTo player, damage, message

  tick: (player) ->
    return if player.hp.atMin()
    message = "Storm clouds brew above %targetName..."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = Thunderstrike
