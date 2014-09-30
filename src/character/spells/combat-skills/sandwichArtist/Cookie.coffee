
Spell = require "../../../base/Spell"

class Cookie extends Spell
  name: "Cookie"
  @element = Cookie::element = Spell::Element.physical
  @cost = Cookie::cost = 100
  @restrictions =
    "SandwichArtist": 1000

  calcDuration: (player) -> super()+3
  
  strPercent: -> 10
  dexPercent: -> 10
  intPercent: -> 10
  conPercent: -> 10
  wisPercent: -> 10
  agiPercent: -> 10
  luckPercent: -> 10
  sentimentalityPercent: -> 10
  pietyPercent: -> 10
  icePercent: -> 10
  firePercent: -> 10
  waterPercent: -> 10
  earthPercent: -> 10
  thunderPercent: -> 10

  cast: (player) ->
    message = "%targetName eats a %spellName!"
    @broadcast player, message

  tick: (player) ->
    damage = @calcDamage()
    message = "%targetName is still boosted by %casterName's \"%spellName\"."
    @broadcast player, message

  uncast: (player) ->
    return if @caster isnt player
    message = "%targetName is no longer under the effects of \"%spellName.\""
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = Cookie