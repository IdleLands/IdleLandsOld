
Spell = require "../../../base/Spell"

class DoubleTap extends Spell
  name: "double tap"
  @element = DoubleTap::element = Spell::Element.physical
  @tiers = DoubleTap::tiers = [
    {name: "double-tap", spellPower: 1, cost: 450, class: "Fighter", level: 1}
    {name: "triple-tap", spellPower: 2, cost: 600, class: "Fighter", level: 51}
  ]

  cast: (player) ->
    @broadcast player,"%casterName is going %spellName crazy on %targetName!"
    @caster.party.currentBattle.doPhysicalAttack @caster, player
    if player.hp.atMin()
      @broadcast player,"%casterName needs not hit %targetName again!"
      return

    @caster.party.currentBattle.doPhysicalAttack @caster, player

    if @spellPower > 1
      if player.hp.atMin()
        @broadcast player,"%casterName needs not hit %targetName again!"
        return
      @caster.party.currentBattle.doPhysicalAttack @caster, player

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = DoubleTap