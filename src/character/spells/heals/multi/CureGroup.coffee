
Spell = require "../../../base/Spell"

class CureGroup extends Spell
  name: "cure group"
  @element = CureGroup::element = Spell::Element.heal
  @cost = CureGroup::cost = (caster) -> if caster.party then caster.party.players.length * 50 else 50

  @restrictions =
    "Cleric": 15

  @canChoose = (caster) ->
    Spell.areAnyPartyMembersBelowMaxHealth caster

  determineTargets: ->
    @targetAllAllies()

  calcDamage: ->
    minStat = (@caster.calc.stat 'wis')/5
    maxStat = (@caster.calc.stat 'wis')/1.5
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName cast %spellName at %targetName and healed %damage HP!"
    @doDamageTo player, -damage, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = CureGroup
