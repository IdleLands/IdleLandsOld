
Spell = require "../../../base/Spell"

class DownloadRAM extends Spell
  name: "DownloadRAM"
  @element = DownloadRAM::element = Spell::Element.physical
  @stat = DownloadRAM::stat = "special"
  @tiers = DownloadRAM::tiers = [
    {name: "single-channel RAM", spellPower: 10, cost: 25, class: "Bitomancer", level: 10}
    {name: "dual-channel RAM", spellPower: 20, cost: 100, class: "Bitomancer", level: 20}
    {name: "triple-channel RAM", spellPower: 30, cost: 300, class: "Bitomancer", level: 40}
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