
Spell = require "../../../base/Spell"
DrunkenStupor = require "./DrunkenStupor.coffee"

class PirateShanty extends Spell
  name: "pirate shanty"
  @element = PirateShanty::element = Spell::Element.physical
  @stat = PirateShanty::stat = "hp"
  @tiers = PirateShanty::tiers = [
    ###*
      * This song buffs the STR of all of the casters allies.
      *
      * @name pirate shanty
      * @requirement {class} Pirate
      * @requirement {hp} 100
      * @requirement {level} 1
      * @effect +20+[3*[11-Bottles/9]]% STR
      * @duration 5-[Bottles/33] rounds
      * @category Pirate
      * @package Spells
    ###
    {name: "pirate shanty", spellPower: 1, cost: 100, class: "Pirate", level: 1}
  ]

  calcDuration: (player) ->
    caster = @caster
    super() + switch
      when caster.special.lte 33 then 4
      when caster.special.lte 66 then 3
      else 2
  
  strPercent: (player) -> 20 + 3*Math.floor(11 - player.special.getValue()/9)

  determineTargets: -> @targetAllAllies()

  cast: (player) ->
    return if player isnt @caster
    message = "%casterName sings a %spellName!"
    @broadcast player, message
    player.profession.drunkPct.add @chance.integer({min: 20, max: 30})
    player.special.sub @chance.integer({min: 10, max: 15})
    if player.profession.drunkPct.lessThan 100
      message = "%casterName is #{player.profession.drunkPct.getValue()}% drunk."
      @broadcast player, message
    else
      stupor = new DrunkenStupor @game, @caster
      stupor.prepareCast()

  tick: (player) ->
    message = "%targetName is boosted by %casterName's %spellName."
    @broadcast player, message

  uncast: (player) ->
    message = "%casterName's %spellName wore off."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = PirateShanty