
Spell = require "../base/Spell"

class Berserk extends Spell
  name: "berserk"
  @element = Berserk::element = Spell::Element.buff
  @cost = Berserk::cost = 0
  @restrictions =
    "Barbarian": 1

  determineTargets: ->
    @caster

  cast: (player) ->
    message = "#{player.name} is going #{@name}!"
    player.special.add 15
    @broadcast message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Berserk