
Spell = require "../../../base/Spell"
_ = require "underscore"

class DrunkenStupor extends Spell
  name: "Drunken Stupor"
  @element = DrunkenStupor ::element = Spell::Element.physical

  determineTargets: -> @caster

  calcDamage: -> Math.floor(0.05*@caster.hp.maximum)

  calcDuration: (player) ->
    switch
      when @caster.special.lte 33 then super()+3
      when @caster.special.lte 66 then super()+2
      else super()+1

  cantAct: -> 1

  cantActMessages: -> "%player tries to act, but %heshe's too drunk to move"

  restSpecial: ->
    switch
      when @caster.special.lte 33 then Math.floor(0.2*@caster.special.maximum)
      when @caster.special.lte 66 then Math.floor(0.25*@caster.special.maximum)
      else Math.floor(0.3*@caster.special.maximum)
    
  cast: ->
    message = "%casterName collapses in a %spellName."
    @broadcast @caster, message
    @caster.profession.drunkPct.toMinimum()

  tick: ->
    damage = @calcDamage()
    message = "In %hisher %spellName, %casterName recovered %damage HP."
    @doDamageTo @caster, -damage, message
    @caster.special.add @restSpecial()

  uncast: ->
    message = "%casterName recovers from %hisher %spellName."
    @broadcast @caster, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = DrunkenStupor