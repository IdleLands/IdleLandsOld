
Spell = require "../../../base/Spell"
DrunkenFrenzy = require "./DrunkenFrenzy.coffee"
DrunkenStupor = require "./DrunkenStupor.coffee"

class GrogDance extends Spell
  name: "grog dance"
  @element = GrogDance::element = Spell::Element.physical
  @stat = GrogDance::stat = "hp"
  @tiers = GrogDance::tiers = [
    `/**
      * This spell sharply increases the casters dex based on how many bottles are remaining.
      *
      * @name grog dance
      * @requirement {class} Pirate
      * @requirement {hp} 600
      * @requirement {level} 15
      * @element physical
      * @targets {self}
      * @effect +[99-Bottles]% DEX
      * @duration 2
      * @category Pirate
      * @package Spells
    */`
    {name: "grog dance", spellPower: 1, cost: 600, class: "Pirate", level: 15}
  ]

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
    if player?.party?.currentBattle?
      message = "%casterName stops %hisher %spellName."
      @broadcast player, message

      return if not @isValidTarget @caster

      frenzy = @game.spellManager.modifySpell new DrunkenFrenzy @game, @caster
      frenzy.prepareCast @caster

      if @caster.profession.drunkPct.atMax()
        stupor = new DrunkenStupor @game, @caster
        stupor.prepareCast @caster

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = GrogDance