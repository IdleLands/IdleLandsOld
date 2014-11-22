
Spell = require "../../../base/Spell"

class Berserk extends Spell
  name: "berserk"
  @element = Berserk::element = Spell::Element.buff
  @tiers = Berserk::tiers = [
    `/**
      * This spell increases Rage.
      *
      * @name berserk
      * @requirement {class} Barbarian
      * @requirement {level} 1
      * @effect +15 Rage
      * @category Barbarian
      * @package Spells
    */`
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