
Spell = require "../base/Spell"
MessageCreator = require "../../system/MessageCreator"

class DoubleTap extends Spell
  name: "double tap"
  @element = DoubleTap::element = Spell::Element.normal
  @cost = DoubleTap::cost = 1
  @restrictions =
    "Fighter": 1

  cast: (player) ->
    @game.broadcast MessageCreator.genericMessage "#{@caster.name} is going double-tap crazy on #{player.name}!"
    @caster.party.currentBattle.doPhysicalAttack @caster, player
    if player.hp.atMin()
      @game.broadcast MessageCreator.genericMessage "#{@caster.name} needs not hit #{player.name} again!"
      return

    @caster.party.currentBattle.doPhysicalAttack @caster, player

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = DoubleTap