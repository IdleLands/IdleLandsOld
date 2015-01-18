
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

  experimentalMonsterPartyGeneration: (party, reduction = 0) ->
    return @generateScalableMonsterParty party if party.level() >= 100

    itemList = @game.componentDatabase.itemStats

    remainingScore = Math.max 500, party.score() - reduction
    possibleMonsters = _.filter @game.componentDatabase.monsters, (monster) -> party.level()-10 < monster.level < party.level()+5

    if possibleMonsters.length is 0
      possibleMonsters.push
        class: _.sample classes
        name: name ? "Pushover Mob"
        level: Math.round party.level()

    monsters = []

    removeFromScore = (score) ->
      remainingScore -= score

    generateMonster = =>
      baseMonster = _.sample possibleMonsters

      if not baseMonster
        @game.captureException (new Error "Failed to generate monster"), extra: {minLevel: party.level()-10, maxLevel: party.level()+5, possibleMonsters: possibleMonsters}

      baseMonster.class = _.sample classes if baseMonster.class is 'Random'

      monster = new Monster baseMonster
      monsters.push monster

      monster.calendar = @game.calendar

      handlePersonalities monster

      return removeFromScore monster.calc.totalItemScore() if monster.calc.totalItemScore() > remainingScore

      addPropsToMonster monster
      nameMonster monster if chance.bool likelihood: 1

      return removeFromScore monster.calc.totalItemScore() if monster.calc.totalItemScore() > remainingScore

      handleEquipment monster

      removeFromScore monster.calc.totalItemScore()

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
      nameOpts.gender = chance.gender().toLowerCase() if chance.bool()
      monster.name = "#{chance.name nameOpts}, the #{monster.name}"

    # even monsters need gear, I guess
    handleEquipment = (monster) =>
      _.each @types, (type) =>
        return if monster.calc.totalItemScore() > remainingScore
        item = @game.equipmentGenerator.generateItem type
        monster.equip item if item and monster.canEquip item

    while remainingScore > 0
      generateMonster()

    new Party @game, monsters

  generateMonster: (maxScore = 99999, baseMonster = _.sample @game.componentDatabase.monsters) ->

    itemList = @game.componentDatabase.itemStats

    if not baseMonster?.level
      @game.errorHandler.captureMessage "GENERATE ERROR, NO LEVEL " + JSON.stringify baseMonster
      return

    baseMonster.class = _.sample classes if baseMonster.class is 'Random'

    monster = new Monster baseMonster

    if chance.integer({min: 0, max: 2}) is 1
      @mergePropInto monster, _.sample itemList['prefix']
      (@mergePropInto monster,  _.sample itemList['prefix']) until chance.integer({min: -1, max: 7**(i = (i+1) or 0)}) isnt 1

    (@mergePropInto monster,  _.sample itemList['prefix-special']) if chance.integer({min: 0, max: 21}) is 1

    (@mergePropInto monster,  _.sample itemList['suffix']) if chance.integer({min: 0, max: 14}) is 1

    _.each @types, (type) =>
      return if monster.calc.totalItemScore() > maxScore
      item = @game.equipmentGenerator.generateItem type
      monster.equip item if item and monster.canEquip item

    monster.personalities = []

    personalityCount = chance.integer min: 0, max: 2

    newPersonalities = _.sample personalities, personalityCount

    (monster._addPersonality pers, Personality::getPersonality pers) for pers in newPersonalities

    monster.personalities.push {alignment: chance.integer({min: -20, max: 20})}

    monster.calendar = @game.calendar

    nameOpts = {middle: chance.bool(), prefix: chance.bool(), suffix: chance.bool()}
    nameOpts.gender = chance.gender().toLowerCase() if chance.bool()

    monster.name = "#{chance.name nameOpts}, the #{monster.name}" if chance.bool likelihood: 1

    monster

  generateScalableMonster: (party, maxScore = party.score()*1.5, name) ->

    chosenClass = _.sample classes
    baseMonster =
      class: chosenClass
      name: name ? "Vector #{chosenClass}"
      level: Math.round party.level()

    monster = @generateMonster maxScore, baseMonster

    for x in [0..100]
      _.each @types, (type) =>
        return if monster.calc.totalItemScore() > maxScore
        item = @game.equipmentGenerator.generateItem type
        monster.equip item if monster.isBetterItem item

    monster

  generateScalableMonsterParty: (party) ->
    monsterCount = chance.integer({min: 1, max: Constants.defaults.game.maxPartyMembers+1})
    monsters = []

    (monsters.push (@generateScalableMonster party, party.score()*chance.floating({min: 1.2, max: 1.3}))) for x in [1..monsterCount]

    party = new Party @game, monsters if monsters.length > 0
    party.isMonsterParty = yes
    party

module.exports = exports = MonsterGenerator
