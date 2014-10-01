
Spell = require "../../../base/Spell"

class SandwichBuff extends Spell
  name: "Sandwich Buff"
  @element = SandwichBuff::element = Spell::Element.physical
  @cost = SandwichBuff::cost = 200
  @restrictions =
    "SandwichArtist": 1000

  calcDuration: (player) -> super()+3

# Random stat buffs from sandwich ingredients; standard for sandwich artist spells
  str: -> this.sandwich.str*this.size/6
  dex: -> this.sandwich.dex*this.size/6
  int: -> this.sandwich.int*this.size/6
  con: -> this.sandwich.con*this.size/6
  wis: -> this.sandwich.wis*this.size/6
  agi: -> this.sandwich.agi*this.size/6
  luck: -> this.sandwich.luck*this.size/6
  sentimentality: -> this.sandwich.sentimentality*this.size/6
  piety: -> this.sandwich.piety*this.size/6
  ice: -> this.sandwich.ice*this.size/6
  fire: -> this.sandwich.fire*this.size/6
  water: -> this.sandwich.water*this.size/6
  earth: -> this.sandwich.earth*this.size/6
  thunder: -> this.sandwich.thunder*this.size/6
  strPercent: -> this.sandwich.strPercent*this.size/6
  dexPercent: -> this.sandwich.dexPercent*this.size/6
  intPercent: -> this.sandwich.intPercent*this.size/6
  conPercent: -> this.sandwich.conPercent*this.size/6
  wisPercent: -> this.sandwich.wisPercent*this.size/6
  agiPercent: -> this.sandwich.agiPercent*this.size/6
  luckPercent: -> this.sandwich.luckPercent*this.size/6
  sentimentalityPercent: -> this.sandwich.sentimentalityPercent*this.size/6
  pietyPercent: -> this.sandwich.pietyPercent*this.size/6
  icePercent: -> this.sandwich.icePercent*this.size/6
  firePercent: -> this.sandwich.firePercent*this.size/6
  waterPercent: -> this.sandwich.waterPercent*this.size/6
  earthPercent: -> this.sandwich.earthPercent*this.size/6
  thunderPercent: -> this.sandwich.thunderPercent*this.size/6

  cast: (player) ->
    # Generate a sandwich name
    this.sandwich = @game.sandwichGenerator.generateSandwich()

    # Monsters have no gold; instead, 50% chance of getting 6 or 12 inch. Could be level-based.
    if player.gold?
      targetGold = player.gold.getValue()
    else
      targetGold = Math.random()*20000
    if targetGold > 10000
      this.size = 12
    else
      this.size = 6
    damage = @calcDamage()
    this.name = "#{this.size}-inch #{this.sandwich.name}"

  tick: (player) ->
    damage = @calcDamage()
    message = "%targetName is digesting %casterName's \"%spellName\"."
    @broadcast player, message

  uncast: (player) ->
    message = "%targetName finished digesting %casterName's \"%spellName.\""
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = SandwichBuff