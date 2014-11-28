
Spell = require "../../../base/Spell"

class DeathGlare extends Spell
  name: "death glare"
  @element = DeathGlare::element = Spell::Element.physical
  @stat = DeathGlare::stat = "hp"
  @tiers = DeathGlare::tiers = [
    `/**
      * This spell lowers the strength of an enemy based on the number of bottles the player has.
      *
      * @name death glare
      * @requirement {class} Pirate
      * @requirement {hp} 350
      * @requirement {level} 7
      * @element physical
      * @targets {enemy} 1
      * @effect -20+[3*[11-Bottles/9]]% STR
      * @duration 4-[Bottles/33] rounds
      * @category Pirate
      * @package Spells
    */`
    {name: "death glare", spellPower: 1, cost: 200, class: "Pirate", level: 7}
  ]

  calcDuration: (player) ->
    switch
      when @caster.special.lte 33 then 3
      when @caster.special.lte 66 then 2
      else 1
  
  strPercent: (player) ->
    if player isnt @caster
      -(20 + 3*Math.floor(11 - player.special.getValue()/9))
    else 0

  determineTargets: -> @targetAllEnemies()

  cast: (player) ->
    message = "%casterName shoots a %spellName at %targetName!"
    @broadcast player, message

  tick: (player) ->
    if player isnt @caster
      message = "%targetName cowers in fear from %casterName's %spellName!"
      @broadcast player, message

  uncast: (player) ->
    return if player is @caster
    message = "%targetName is no longer affected by %casterName's %spellName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = DeathGlare