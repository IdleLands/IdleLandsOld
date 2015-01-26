
Spell = require "../../../base/Spell"

class RelentlessAssault extends Spell
  name: "relentless assault"
  @element = RelentlessAssault::element = Spell::Element.physical
  @stat = RelentlessAssault::stat = "special"
  @tiers = RelentlessAssault::tiers = [
    `/**
      * The caster performs two additional attacks every round, losing focus gradually.
      *
      * @name relentless assault
      * @requirement {class} Archer
      * @requirement {Focus} 30 (only cast if Focus >= 70)
      * @requirement {level} 50
      * @element physical
      * @targets {self}
      * @effect -25 Focus per round
      * @effect +2 physical attack per round
      * @duration 10 rounds (cancelled if focus drops below 25)
      * @category Archer
      * @package Spells
    */`
    {name: "relentless assault", spellPower: 1, cost: 30, class: "Archer", level: 50}
  ]

  @canChoose = (caster) -> caster.special.getValue() > 70

  calcDuration: (player) -> super()+10

  determineTargets: -> @caster

  cast: (player) ->
    message = "%casterName begins a %spellName!"
    @broadcast player, message

  tick: (player) ->
    message = "%casterName attacks in a %spellName!"
    @broadcast player, message
    @game.battle.doPhysicalAttack player
    @game.battle.doPhysicalAttack player
    if player.special.getValue() > 25
      player.special.sub 25
    else @uncast player

  uncast: (player) ->
    message = "%casterName no longer has the focus to maintain %hisher %spellName."
    @broadcast player, message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.start": @tick

module.exports = exports = RelentlessAssault