
Spell = require "../../../base/Spell"

class DoubleTap extends Spell
  name: "double tap"
  @element = DoubleTap::element = Spell::Element.physical
  @cost = DoubleTap::cost = 450
  @restrictions =
    "Fighter": 1

  cast: (player) ->
    @broadcast player,"%casterName is going double-tap crazy on %targetName!"
    @caster.party.currentBattle.doPhysicalAttack @caster, player
    if player.hp.atMin()
      @broadcast player,"%casterName needs not hit %targetName again!"
      return

    @caster.party.currentBattle.doPhysicalAttack @caster, player

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = DoubleTap