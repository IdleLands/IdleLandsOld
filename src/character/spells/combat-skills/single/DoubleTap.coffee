
Spell = require "../../../base/Spell"

class DoubleTap extends Spell
  name: "double tap"
  @element = DoubleTap::element = Spell::Element.physical
  @cost = DoubleTap::cost = 450
  @restrictions =
    "Fighter": 1

  cast: (player) ->
    @broadcast "#{@caster.name} is going double-tap crazy on #{player.name}!"
    @caster.party.currentBattle.doPhysicalAttack @caster, player
    if player.hp.atMin()
      @broadcast "#{@caster.name} needs not hit #{player.name} again!"
      return

    @caster.party.currentBattle.doPhysicalAttack @caster, player

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = DoubleTap