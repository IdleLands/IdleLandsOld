
Spell = require "../../../base/Spell"

class Prone extends Spell
  @name = Prone::name = "prone"
  @element = Prone::element = Spell::Element.physical
  @cost = Prone::cost = 0
  @isStatusEffect = yes

  cantAct: -> 1

  cantActMessages: -> "%player was knocked prone"

  calcDuration: (player) -> super()+1

  calcDamage: -> 0

  constructor: (@game, @caster, forced) ->
    super @game, @caster, forced
    @bindings =
      doSpellCast: ->
      doSpellUncast: ->
      "combat.self.turn.end": ->

module.exports = exports = Prone
