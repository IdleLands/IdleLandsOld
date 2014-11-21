
Spell = require "../../../base/Spell"

class DownloadRAM extends Spell
  name: "DownloadRAM"
  @element = DownloadRAM::element = Spell::Element.physical
  @stat = DownloadRAM::stat = "special"
  @tiers = DownloadRAM::tiers = [
    ###*
      * This spell forces the caster to download more ram, modifying their stats.
      *
      * @name single-channel RAM
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 25
      * @requirement {level} 10
      * @effect -10% INT
      * @effect +10% DEX
      * @effect +10% AGI
      * @category Bitomancer
      * @package Spells
    ###
    {name: "single-channel RAM", spellPower: 10, cost: 25, class: "Bitomancer", level: 10}
    ###*
      * This spell forces the caster to download more ram, modifying their stats.
      *
      * @name dual-channel RAM
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 100
      * @requirement {level} 20
      * @effect -20% INT
      * @effect +20% DEX
      * @effect +20% AGI
      * @category Bitomancer
      * @package Spells
    ###
    {name: "dual-channel RAM", spellPower: 20, cost: 100, class: "Bitomancer", level: 20}
    ###*
      * This spell forces the caster to download more ram, modifying their stats.
      *
      * @name triple-channel RAM
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 300
      * @requirement {level} 40
      * @effect -30% INT
      * @effect +30% DEX
      * @effect +30% AGI
      * @category Bitomancer
      * @package Spells
    ###
    {name: "triple-channel RAM", spellPower: 30, cost: 300, class: "Bitomancer", level: 40}
    ###*
      * This spell forces the caster to download more ram, modifying their stats.
      *
      * @name quad-channel RAM
      * @requirement {class} Bitomancer
      * @requirement {Bitrate} 500
      * @requirement {level} 70
      * @effect -50% INT
      * @effect +50% DEX
      * @effect +50% AGI
      * @category Bitomancer
      * @package Spells
    ###
    {name: "quad-channel RAM", spellPower: 50, cost: 500, class: "Bitomancer", level: 70}
  ]

  determineTargets: -> @caster

  calcDuration: (player) ->
    super()+2

  intPercent: (player) -> -@spellPower
  agiPercent: (player) -> @spellPower
  dexPercent: (player) -> @spellPower

  cast: (player) ->
    message = "%casterName downloads some %spellName!"
    @broadcast player, message

  tick: (player) ->
    message = "%targetName is boosted by %hisher %spellName."
    @broadcast player, message

  uncast: (player) ->
    message = "%casterName's %spellName stopped working."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = DownloadRAM