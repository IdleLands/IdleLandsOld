
Spell = require "../../../base/Spell"

class DDoS extends Spell
  name: "DDoS"
  @element = DDoS::element = Spell::Element.physical
  @stat = DDoS::stat = "special"
  @tiers = DDoS::tiers = [
    `/**
      * This spell stuns and lowers some stats for one enemy.
      *
      * @name DDoS attack
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 300
      * @requirement {level} 30
      * @effect -25% STR
      * @effect -25% AGI
      * @effect STUN
      * @duration 1 round
      * @category Bitomancer
      * @package Spells
    */`
    {name: "DDoS attack", spellPower: 1, cost: 300, class: "Bitomancer", level: 30}
    `/**
      * This spell stuns and lowers some stats for one enemy.
      *
      * @name persistent DDoS attack
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 1000
      * @requirement {level} 60
      * @effect -50% STR
      * @effect -50% AGI
      * @effect STUN
      * @duration 2 rounds
      * @category Bitomancer
      * @package Spells
    */`
    {name: "persistent DDoS attack", spellPower: 2, cost: 1000, class: "Bitomancer", level: 60}
  ]

  cantAct: -> if @chance.bool({likelihood:25*@spellPower}) then 1 else 0

  cantActMessages: -> "%player tries to act, but the packets are dropped"

  determineTargets: ->
    @targetSomeEnemies size: 1

  calcDuration: (player) ->
    super() + 1 + @spellPower

  strPercent: -> -25*@spellPower
  agiPercent: -> -25*@spellPower

  cast: (player) ->
    message = "%casterName targets %targetName with a %spellName!"
    @broadcast player, message

  tick: (player) ->
    message = "%targetName is still under heavy load from %casterName's %spellName."
    @broadcast player, message

  uncast: (player) ->
    @caster.special.add switch
      when @caster.level.getValue() < 30 then 300
      else 1000
    message = "%casterName ends %hisher %spellName on %targetName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = DDoS