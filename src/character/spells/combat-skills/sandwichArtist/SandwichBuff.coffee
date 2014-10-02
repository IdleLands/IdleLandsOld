
Spell = require "../../../base/Spell"

class SandwichBuff extends Spell
  name: "Sandwich Buff"
  @element = SandwichBuff::element = Spell::Element.physical
  @cost = SandwichBuff::cost = 200
  @restrictions =
    "SandwichArtist": 1000

  calcDuration: (player) -> super()+3

# Random stat buffs from sandwich ingredients; standard for sandwich artist spells
  str: -> @sandwich.str*@size/6
  dex: -> @sandwich.dex*@size/6
  int: -> @sandwich.int*@size/6
  con: -> @sandwich.con*@size/6
  wis: -> @sandwich.wis*@size/6
  agi: -> @sandwich.agi*@size/6
  luck: -> @sandwich.luck*@size/6
  sentimentality: -> @sandwich.sentimentality*@size/6
  piety: -> @sandwich.piety*@size/6
  ice: -> @sandwich.ice*@size/6
  fire: -> @sandwich.fire*@size/6
  water: -> @sandwich.water*@size/6
  earth: -> @sandwich.earth*@size/6
  thunder: -> @sandwich.thunder*@size/6
  xp: -> @sandwich.xp*@size/6
  gold: -> @sandwich.gold*@size/6
  strPercent: -> @sandwich.strPercent*@size/6
  dexPercent: -> @sandwich.dexPercent*@size/6
  intPercent: -> @sandwich.intPercent*@size/6
  conPercent: -> @sandwich.conPercent*@size/6
  wisPercent: -> @sandwich.wisPercent*@size/6
  agiPercent: -> @sandwich.agiPercent*@size/6
  luckPercent: -> @sandwich.luckPercent*@size/6
  sentimentalityPercent: -> @sandwich.sentimentalityPercent*@size/6
  pietyPercent: -> @sandwich.pietyPercent*@size/6
  icePercent: -> @sandwich.icePercent*@size/6
  firePercent: -> @sandwich.firePercent*@size/6
  waterPercent: -> @sandwich.waterPercent*@size/6
  earthPercent: -> @sandwich.earthPercent*@size/6
  thunderPercent: -> @sandwich.thunderPercent*@size/6
  crit: -> @sandwich.crit*@size/6
  dodge: -> @sandwich.dodge*@size/6
  prone: -> @sandwich.prone*@size/6
  power: -> @sandwich.power*@size/6
  silver: -> @sandwich.silver*@size/6
  deadeye: -> @sandwich.deadeye*@size/6
  defense: -> @sandwich.defense*@size/6
  glowing: -> @sandwich.glowing*@size/6

  cast: (player) ->
    # Generate a sandwich name
    @sandwich = @game.sandwichGenerator.generateSandwich()

    # Monsters have no gold; instead, 50% chance of getting 6 or 12 inch. Could be level-based.
    if player.gold?
      if player.gold.getValue? # Shouldn't be necessary, but issue occurred once
        targetGold = player.gold.getValue()
      else
        targetGold = Math.random()*20000
    else
      targetGold = Math.random()*20000
    if targetGold > 10000
      @size = 12
    else
      @size = 6
    damage = @calcDamage()
    @name = "#{@size}-inch #{@sandwich.name}"

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