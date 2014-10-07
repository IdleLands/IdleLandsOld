
Spell = require "../../../base/Spell"

class Berserk extends Spell
  name: "berserk"
  @element = Berserk::element = Spell::Element.buff
  @tiers = Berserk::tiers = [
    {name: "berserk", spellPower: 1, cost: 0, class: "Barbarian", level: 1}
  ]

  determineTargets: ->
    @caster

  cast: (player) ->
    message = "%casterName is going %spellName!"
    player.special.add 15
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Berserk