
Spell = require "../../../base/Spell"
MessageCreator = require "../../../../system/MessageCreator"

class FadeAway extends Spell
  name: "fade away"
  @element = FadeAway::element = Spell::Element.heal
  @cost = FadeAway::cost = 0

  @restrictions =
    "Rogue": 10

  @canChoose = (caster) ->
    caster.special.ltePercent 25

  determineTargets: -> @caster

  calcDamage: -> 30

  cast: ->
    @caster.profession.resetCombo()
    damage = @calcDamage()
    message = "%casterName used %spellName and restored %damage Stamina!"

    extra =
      casterName: @caster.name
      spellName: @name

    message = MessageCreator.doStringReplace message, @caster, extra

    @caster.party?.currentBattle?.takeStatFrom @caster, @caster, -damage, @determineType(), 'special', @, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = FadeAway
