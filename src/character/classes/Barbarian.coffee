
Class = require "./../base/Class"

class Barbarian extends Class

  baseHp: 200
  baseHpPerLevel: 25
  baseHpPerCon: 10

  baseMp: 0
  baseMpPerLevel: -10
  baseMpPerInt: -5

  baseConPerLevel: 6
  baseDexPerLevel: 2
  baseAgiPerLevel: 0
  baseStrPerLevel: 6
  baseIntPerLevel: -3
  baseWisPerLevel: -3

  itemScore: (player, item) ->
    item.con*2 +
    item.str*2 -
    item.wis -
    item.int

  physicalAttackChance: (player) ->
    if player.special.getValue() > 70 then 30 else 5

  minDamage: (player) ->
    player.calc.damage()*0.40

  strPercent: (player) ->
    player.special.getValue()

  dexPercent: -> -25
  agiPercent: -> -25

  damageTaken: (player, attacker, damage, skillType, spell, reductionType) ->
    return 0 if reductionType isnt "hp" or skillType isnt "magical"
    -Math.floor damage/2

  events: {}

  load: (player) ->
    super player
    player.special.maximum = 100
    player.special.name = "Rage"

    player.on "explore.walk", @events.walk = -> player.special.sub 1
    player.on "combat.self.damaged", @events.hitReceived = -> player.special.add 5
    player.on "combat.self.damage", @events.hitGiven = -> player.special.sub 2
    player.on "combat.ally.killed", @events.allyDeath = -> player.special.add 10
    player.on "combat.self.kill", @events.enemyDeath = -> player.special.sub 15
    player.on "combat.self.killed", @events.selfDead = -> player.special.toMinimum()
    player.on "combat.self.deflect", @events.selfDeflect = (target) =>
      probability = (Math.floor player.level.getValue()/10)*5
      if @chance.bool({likelihood: probability})
        player.party.currentBattle.doPhysicalAttack player, target, yes

  unload: (player) ->
    player.special.maximum = 0
    player.special.name = ""

    player.off "explore.walk", @events.walk
    player.off "combat.self.damaged", @events.hitReceived
    player.off "combat.self.damage", @events.hitGiven
    player.off "combat.ally.killed", @events.allyDeath
    player.off "combat.self.kill", @events.enemyDeath
    player.off "combat.self.killed", @events.selfDead
    player.off "combat.self.deflect", @events.selfDeflect

module.exports = exports = Barbarian