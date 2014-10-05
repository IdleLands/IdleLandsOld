
Spell = require "../../../base/Spell"
DrunkenFrenzy = require "./DrunkenFrenzy.coffee"
DrunkenStupor = require "./DrunkenStupor.coffee"

class GrogDance extends Spell
  name: "Grog Dance"
  @element = GrogDance ::element = Spell::Element.physical
  @cost = GrogDance ::cost = 600
  @stat = GrogDance::stat = "hp"
  @restrictions =
    "Pirate": 15

  calcDuration: (player) -> super()+2
  
  dexPercent: (player) -> 99 - player.special.getValue()

  determineTargets: -> @caster

  cast: (player) ->
    message = "%casterName begins performing a %spellName!"
    @broadcast player, message
    @frenzyTarget = @targetSomeEnemies size: 1

  tick: (player) ->
# Duration effects still broken?
    if player?
      message = "%casterName is boosted by %hisher %spellName."
      # This would be @caster, but an issue arose.
      player.profession.drunkPct.add @chance.integer({min: 15, max: 30})
      @caster.special.sub @chance.integer({min: 10, max: 15})
      if @caster.profession.drunkPct.lessThan 100
        message = "%casterName is #{@caster.profession.drunkPct.getValue()}% drunk."
        @broadcast @caster, message
      else
      # End the dance. Stupor occurs in uncast so it can follow the frenzy.
        @turns[@caster.name] = 0

  uncast: (player) ->
    if player.party?.currentBattle?
      message = "%casterName stops %hisher %spellName."
      @broadcast player, message
      frenzy = @game.spellManager.modifySpell new DrunkenFrenzy @game, @caster
      frenzy.prepareCast()
      if @caster.profession.drunkPct.atMax()
        stupor = new DrunkenStupor @game, @caster
        stupor.prepareCast()

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = GrogDance