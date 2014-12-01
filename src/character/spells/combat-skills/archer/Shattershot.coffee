
Spell = require "../../../base/Spell"
_ = require "underscore"

class Shattershot extends Spell
  name: "shattershot"
  stat: @stat = "special"
  @element = Shattershot::element = Spell::Element.physical
  @tiers = Shattershot::tiers = [
    `/**
      * This skill deals a large amount of damage, inflicting shatter and prone.
      *
      * @name shattershot
      * @requirement {class} Archer
      * @requirement {Focus} 25
      * @requirement {level} 35
      * @element physical
      * @targets {enemy} 1
      * @effect shatter, prone
      * @minDamage 0.75*[str+dex]
      * @maxDamage 1.5*[str+dex]
      * @category Archer
      * @package Spells
    */`
    {name: "shattershot", spellPower: 1, cost: 25, class: "Archer", level: 35}
  ]

  calcDamage: ->
    minStat = (@caster.calc.stats ['str', 'dex']) * 0.75
    maxStat = (@caster.calc.stats ['str', 'dex']) * 1.5
    super() + @minMax minStat, maxStat

  cast: (player) ->
    damage = @calcDamage()
    message = "%casterName knocked %targetName to the floor with a %spellName, dealing %damage damage!"
    @doDamageTo player, damage, message

    return if player.hp.atMin()
    @caster.party?.currentBattle?.doBattleEffects ['Shatter','Prone'], @caster, player

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Shattershot