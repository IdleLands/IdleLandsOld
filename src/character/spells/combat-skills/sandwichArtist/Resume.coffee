
Spell = require "../../../base/Spell"
Chance = require "Chance"
chance = new Chance

class Resume extends Spell
  name: "Resume"
  @element = Resume::element = Spell::Element.physical
  @cost = Resume::cost = 10
  @restrictions =
    "SandwichArtist": 1
  @canChoose = (player) -> (player.hp.asPercent() <= 25)

  cantAct: -> @resumeRejected

  cantActMessages: -> "#{@caster.name} is still fuming about the resume %heshe gave to %player!"

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