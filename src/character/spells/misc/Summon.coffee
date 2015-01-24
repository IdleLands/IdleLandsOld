
Spell = require "../../base/Spell"
Event = require "../../../event/Event"
Equipment = require "../../../item/Equipment"
_ = require "lodash"

requireDir = require "require-dir"
classProtos = requireDir "../../classes"
baseStats = ['Str', 'Dex', 'Con', 'Agi', 'Int', 'Wis', 'Luck']

monsters =
  Necromancer: [
    {name: "zombie",          statMult: 0.5,  slotCost: 1, restrictLevel: 5,   restrictClasses: ['Monster']}
    {name: "skeleton",        statMult: 0.8,  slotCost: 1, restrictLevel: 25,  restrictClasses: ['Generalist', 'Rogue', 'Mage', 'Cleric', 'Barbarian', 'Fighter']}
    {name: "wraith",          statMult: 1.1,  slotCost: 1, restrictLevel: 55}
    {name: "vampire",         statMult: 1.0,  slotCost: 2, restrictLevel: 70,  baseStats: {vampire: 10}}
    {name: "plaguebringer",   statMult: 1.0,  slotCost: 2, restrictLevel: 70,  baseStats: {venom: 10}}
    {name: "ghoul",           statMult: 1.0,  slotCost: 2, restrictLevel: 70,  baseStats: {poison: 10}}
    {name: "dracolich",       statMult: 1.35, slotCost: 2, restrictLevel: 85,  baseStats: {mirror: 1}, requireCollectibles: ["Undead Draygon Scale"]}
    {name: "demogorgon",      statMult: 1.75, slotCost: 4, restrictLevel: 150, requireCollectibles: ["Gorgon Snake"]}
  ]

class Summon extends Spell
  name: "summon"
  @element = Summon::element = Spell::Element.none
  @tiers = Summon::tiers = [
    `/**
      * This spell summons a variety of monsters under the command of the caster.
      *
      * @name summon
      * @requirement {class} Necromancer
      * @requirement {mp} 0.15*maxMp
      * @requirement {level} 85
      * @category Necromancer
      * @package Spells
    */`
    {name: "summon", spellPower: 1, cost: ((caster) -> Math.round caster.mp.maximum * 0.15), class: "Necromancer", level: 5}
  ]

  @canChoose = (caster) ->
    not caster.isMonster and not caster.special.atMax()

  getPossibleMonstersForCaster: ->
    _(monsters[@caster.professionName])
      .reject (monster) => monster.restrictLevel > @caster.level.getValue()
      .reject (monster) => monster.requireCollectibles?.length > 0 and not @hasCollectibles @caster, monster.requireCollectibles
      .reject (monster) => monster.slotCost > @caster.special.maximum - @caster.special.getValue()
      .value()

  determineTargets: -> @caster

  cast: ->
    chosenBaseMonster = _.clone _.sample @getPossibleMonstersForCaster()
    chosenBaseMonster.class = _.sample chosenBaseMonster.restrictClasses if chosenBaseMonster.restrictClasses
    chosenBaseMonster.level = @caster.level.getValue()

    isFail = @chance.bool {likelihood: 5}

    otherParty = _.sample _.without @caster.party.currentBattle.parties, @caster.party
    joinParty = if isFail then otherParty else @caster.party

    monster = @game.monsterGenerator.experimentalMonsterGeneration chosenBaseMonster, @caster.calc.totalItemScore(), if isFail then @caster.party else otherParty
    monster.name = "#{@caster.name}'s #{monster.name}"
    monster.hp.toMaximum()
    monster.mp.toMaximum()
    monster.isPet = yes
    monster.needsToRecalcCombat = yes

    basePhylact = (_.clone chosenBaseMonster.baseStats) or {}
    [basePhylact.type, basePhylact.class, basePhylact.name] = ["monster", "newbie", "phylactic essence"]

    currentProto = classProtos[monster.professionName].prototype

    applicableStats = _.reject baseStats, (stat) -> currentProto["base#{stat}PerLevel"] is 0

    _.each applicableStats, (stat) =>
      basePhylact[stat.toLowerCase()] = currentProto["base#{stat}PerLevel"] * @caster.level.getValue() * chosenBaseMonster.statMult

    specialBuffs = Math.floor @caster.level.getValue() / 40
    basePhylact[_.sample Event::specialStats] = 1 for i in [0..specialBuffs]

    monster.equipment.push new Equipment basePhylact

    message = "%casterName summoned <player.name>#{monster.getName()}</player.name> to the battlefield#{if isFail then ', but failed, and it ended up as a foe' else ''}!"
    @broadcast @caster, message

    joinParty.recruit [monster]

    monster.party.currentBattle.turnOrder.push monster

    @caster.special.add chosenBaseMonster.slotCost if not isFail

    monster.on "combat.self.killed", ->
      monster.canFade = yes

    monster.on "combat.round.end", =>
      if monster.needsToRecalcCombat
        monster.party.currentBattle.calculateTurnOrder()
        monster.needsToRecalcCombat = no
        return

      return if not monster.canFade
      @caster.special.sub chosenBaseMonster.slotCost if not isFail
      monster.party.playerLeave monster, yes
      @caster.party?.currentBattle.calculateTurnOrder()

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = Summon
