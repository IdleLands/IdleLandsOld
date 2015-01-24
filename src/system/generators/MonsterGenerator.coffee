
_ = require "lodash"
Monster = require "../../character/npc/Monster"
Generator = require "./Generator"
Constants = require "./../utilities/Constants"
Party = require "../../event/Party"
Personality = require "../../character/base/Personality"
chance = new (require "chance")()

requireDir = require "require-dir"
personalities = _.keys requireDir "../../character/personalities", recurse: yes
classes = _.keys requireDir "../../character/classes", recurse: yes

class MonsterGenerator extends Generator
  constructor: (@game) ->

  experimentalMonsterPartyGeneration: (party, reduction = 0, monsterList = []) ->
    return @generateScalableMonsterParty party if party.level() >= 100

    remainingScore = Math.max 500, party.score() - reduction
    possibleMonsters = if monsterList.length > 0 then monsterList else _.filter @game.componentDatabase.monsters, (monster) -> party.level()-10 < monster.level < party.level()+5

    if possibleMonsters.length is 0
      possibleMonsters.push
        class: _.sample classes
        name: name ? "Pushover Mob"
        level: Math.round party.level() or 1

    monsters = []

    while remainingScore > 0
      baseMonster = _.sample possibleMonsters
      newMonster = @experimentalMonsterGeneration baseMonster, remainingScore, party
      monsters.push newMonster
      remainingScore -= newMonster.calc.totalItemScore()

    new Party @game, monsters

  experimentalMonsterGeneration: (baseMonster, remainingScore, party) ->

    itemList = @game.componentDatabase.itemStats

    handlePersonalities = (monster) ->
      monster.personalities = []
      personalityCount = chance.integer min: 0, max: 2
      newPersonalities = _.sample personalities, personalityCount

      #give it some random personalities
      (monster._addPersonality pers, Personality::getPersonality pers) for pers in newPersonalities

      #give it a random alignment
      monster.personalities.push {alignment: chance.integer({min: -20, max: 20})}

    # some prefixes and suffixes
    addPropsToMonster = (monster) =>
      if chance.integer({min: 0, max: 2}) is 1 and monster.calc.totalItemScore() < remainingScore
        @mergePropInto monster, _.sample itemList['prefix']

      if chance.integer({min: 0, max: 2}) is 1 and monster.calc.totalItemScore() < remainingScore
        (@mergePropInto monster,  _.sample itemList['prefix']) until chance.integer({min: -1, max: 7**(i = (i+1) or 0)}) isnt 1

      if chance.integer({min: 0, max: 21}) is 1 and monster.calc.totalItemScore() < remainingScore
        @mergePropInto monster,  _.sample itemList['prefix-special']

      if chance.integer({min: 0, max: 14}) is 1 and monster.calc.totalItemScore() < remainingScore
        @mergePropInto monster,  _.sample itemList['suffix']

    # sometimes, monsters get funny names
    nameMonster = (monster) ->
      nameOpts = {middle: chance.bool(), prefix: chance.bool(), suffix: chance.bool()}
      nameOpts.gender = (if baseMonster.gender then baseMonster.gender else chance.gender().toLowerCase()) if chance.bool()
      monster.name = "#{chance.name nameOpts}, the #{monster.name}"

    # even monsters need gear, I guess
    handleEquipment = (monster) =>
      _.each @types, (type) =>
        return if monster.calc.totalItemScore() > remainingScore
        item = @game.equipmentGenerator.generateItem type
        monster.equip item if item and monster.canEquip item

    doGenerate = =>
      baseMonster.class = _.sample classes if baseMonster.class is 'Random'

      monster = new Monster baseMonster
      monster.shouldMirror = baseMonster.mirror

      monster.calendar = @game.calendar

      handlePersonalities monster

      return monster if monster.calc.totalItemScore() > remainingScore

      addPropsToMonster monster
      nameMonster monster if chance.bool likelihood: 1

      return monster if monster.calc.totalItemScore() > remainingScore

      handleEquipment monster

      monster

    monster = doGenerate()

    monster.mirror party if monster.shouldMirror

    monster

  generateScalableMonster: (party, maxScore = party.score()*1.5, name) ->

    chosenClass = _.sample classes
    baseMonster =
      class: chosenClass
      name: name ? "Vector #{chosenClass}"
      level: Math.round party.level() or 1

    monster = @experimentalMonsterGeneration baseMonster, maxScore

    for x in [0..100]
      _.each @types, (type) =>
        return if monster.calc.totalItemScore() > maxScore
        item = @game.equipmentGenerator.generateItem type
        monster.equip item if monster.isBetterItem item

    monster

  generateScalableMonsterParty: (party) ->
    monsterCount = chance.integer({min: 1, max: Constants.defaults.game.maxPartyMembers+1})
    monsters = []

    (monsters.push (@generateScalableMonster party, party.score()*chance.floating({min: 1.0, max: 1.3}))) for x in [1..monsterCount]

    party = new Party @game, monsters if monsters.length > 0
    party.isMonsterParty = yes
    party

module.exports = exports = MonsterGenerator
