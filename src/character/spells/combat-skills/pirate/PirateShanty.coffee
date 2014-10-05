
Spell = require "../../../base/Spell"
DrunkenStupor = require "./DrunkenStupor.coffee"

class PirateShanty extends Spell
  name: "Pirate Shanty"
  @element = PirateShanty ::element = Spell::Element.physical
  @cost = PirateShanty ::cost = 50
  @stat = PirateShanty::stat = "hp"
  @restrictions =
    "Pirate": 1

  calcDuration: (player) ->
    switch
      when @caster.special.lte 33 then 3
      when @caster.special.lte 66 then 2
      else 1
  
  strPercent: (player) -> 20 + 3*Math.floor(11 - player.special.getValue()/9)

  determineTargets: -> @targetAllAllies()

  cast: (player) ->
    return if player isnt @caster
    message = "%casterName begins performing a %spellName!"
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
    message = "%targetName is boosted by %casterName's %spellName!"
    @broadcast player, message

  uncast: (player) ->
    message = "%targetName is no longer boosted by %casterName's %spellName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = PirateShanty