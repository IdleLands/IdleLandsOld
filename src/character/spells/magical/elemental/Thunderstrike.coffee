
Spell = require "../../../base/Spell"

class Thunderstrike extends Spell
  name: "thunderstrike"
  @element = Thunderstrike::element = Spell::Element.thunder
  @tiers = Thunderstrike::tiers = [
    `/**
      * This spell has a delayed effect on striking, but does more damage the longer it takes.
      *
      * @name thunderstrike
      * @requirement {class} Mage
      * @requirement {mp} 375
      * @requirement {level} 7
      * @element thunder
      * @targets {enemy} 1
      * @minDamage [int*0.25*rounds]
      * @maxDamage [int*0.40*rounds-1]
      * @duration [1-3] rounds
      * @category Mage
      * @package Spells
    */`
    {name: "thunderstrike", spellPower: 1, cost: 375, class: "Mage", level: 7}
  ]

  calcDuration: -> super()+(@chance.integer min: 1, max: 3)

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