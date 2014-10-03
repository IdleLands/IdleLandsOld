
Spell = require "../../../base/Spell"

class Revive extends Spell
  name: "revive"
  @element = Revive::element = Spell::Element.heal
  @cost = Revive::cost = 500

  @restrictions =
    "Cleric": 20

  determineTargets: ->
    @targetAllAllies includeDead: yes, includeLiving: no

  calcDamage: ->
    super() + 25

  cast: (player) ->
    damage = @calcDamage()
    damage = parseInt player.hp.maximum*damage*0.01
    damage = 1 if damage < 1
    message = "%casterName cast %spellName on %targetName and revived %himher to %damage HP!"
    @doDamageTo player, -damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Revive
