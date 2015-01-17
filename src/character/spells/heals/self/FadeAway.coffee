
Spell = require "../../../base/Spell"
MessageCreator = require "../../../../system/handlers/MessageCreator"

class FadeAway extends Spell
  name: "fade away"
  @element = FadeAway::element = Spell::Element.heal
  @tiers = FadeAway::tiers = [
    `/**
      * This spell recovers some stamina. Only selectable if you have <=25% hp.
      *
      * @name fade away
      * @requirement {class} Rogue
      * @requirement {level} 10
      * @element heal
      * @targets {self}
      * @effect +30 Stamina
      * @category Rogue
      * @package Spells
    */`
    {name: "fade away", spellPower: 1, cost: 0, class: "Rogue", level: 10}
  ]

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
