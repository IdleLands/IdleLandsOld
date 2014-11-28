
Spell = require "../../../base/Spell"

class Resume extends Spell
  name: "résumé"
  @element = Resume::element = Spell::Element.physical
  @tiers = Resume::tiers = [
    `/**
      * This skill attempts to give a resume to a target, assuming the caster has <=25% HP. Resumes can be accepted or rejected.
      * The outcome can mean gaining or losing gold.
      *
      * @name resume
      * @requirement {class} SandwichArtist
      * @requirement {mp} 10
      * @requirement {level} 1
      * @element physical
      * @duration 1 round
      * @effect {if-rejected} STUN
      * @category SandwichArtist
      * @package Spells
    */`
    {name: "résumé", spellPower: 1, cost: 10, class: "SandwichArtist", level: 1}
  ]
  @canChoose = (player) -> (player.hp.asPercent() <= 25)

  cantAct: -> @resumeRejected

  cantActMessages: -> "#{@caster.name} is still fuming about the résumé %heshe gave to %player!"

  calcDuration: -> super()+1

  determineTargets: ->
    @targetSomeEnemies size: 1

  cast: (player) ->
    message = "Out of desperation, %casterName handed %targetName a %spellName."
    @broadcast player, message
    # Monsters have no gold, and will therefore be unable to pay.
    reqGold = 100*player.level.getValue()
    if player.gold?
      targetGold = player.gold.getValue()
    else
      targetGold = 0
    if targetGold > reqGold
      message = "%targetName hired %casterName for a part-time gig (#{reqGold} gold earned)."
      @broadcast player, message
      player.gainGold -reqGold
      @caster.gainGold reqGold
    else
      message = "%targetName turned down %casterName. %casterName shoved %himher to the ground!"
      @broadcast player, message
      @resumeRejected = yes

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: ->
      "combat.self.turn.end": ->

module.exports = exports = Resume