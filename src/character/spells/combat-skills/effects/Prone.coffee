
Spell = require "../../../base/Spell"

class Prone extends Spell
  @name = Prone::name = "prone"
  @element = Prone::element = Spell::Element.physical
  @cost = Prone::cost = 0
  @isStatusEffect = yes

  cantAct: -> 1

  cantActMessages: -> "%player was knocked prone"

  calcDuration: -> 1

  calcDamage: -> 0

  cast: ->

  tick: ->

  uncast: ->

  constructor: (@game, @caster, forced) ->
    super @game, @caster, forced
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = Prone
