
_ = require "lodash"
Monster = require "../character/npc/Monster"
Generator = require "./Generator"
Constants = require "./Constants"
Party = require "../event/Party"
Personality = require "../character/base/Personality"
chance = new (require "chance")()

requireDir = require "require-dir"
personalities = _.keys requireDir "../character/personalities", recurse: yes
classes = _.keys requireDir "../character/classes", recurse: yes

class MonsterGenerator extends Generator
  constructor: (@game) ->

  generateMonster: (maxScore = 99999, baseMonster = _.sample @game.componentDatabase.monsters) ->

    if not baseMonster
      console.error "COULD NOT GENERATE MONSTER"
      return

    itemList = @game.componentDatabase.itemStats

    if not baseMonster.level
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

    nameOpts = {middle: chance.bool(), prefix: chance.bool()}
    nameOpts.gender = chance.gender().toLowerCase() if chance.bool()

    monster.name = "#{chance.name nameOpts}, the #{monster.name}" if chance.bool likelihood: 1

    monster

  generateMonsterAtScore: (targetScore = 100, tolerance = 0.1) ->
    testMonster = (monster) ->
      return false if not monster
      baseScore = monster.calc.totalItemScore()
      flux = baseScore * tolerance
      baseScore-flux <= targetScore <= baseScore+flux

    tries = 0
    monster = @generateMonster targetScore
    monster = (@generateMonster targetScore) while (not testMonster monster) and tries++ < 100

    monster

  generateMonsterParty: (targetScore = 100, tolerance = 0.1) ->
    monsterCount = chance.integer({min: 1, max: Constants.defaults.game.maxPartyMembers})
    monsters = []

    (monsters.push @generateMonsterAtScore (targetScore/monsterCount), tolerance) for x in [1..monsterCount]

    new Party @game, monsters if monsters.length > 0

  generateScalableMonster: (party, maxScore = party.score()*1.5) ->

    chosenClass = _.sample classes
    baseMonster =
      class: chosenClass
      name: "Vector #{chosenClass}"
      level: party.level()

    monster = @generateMonster maxScore, baseMonster

    for x in [0..100]
      _.each @types, (type) =>
        return if monster.calc.totalItemScore() > maxScore
        item = @game.equipmentGenerator.generateItem type
        monster.equip item if monster.isBetterItem item

    monster

  generateScalableMonsterParty: (party) ->
    monsterCount = chance.integer({min: 1, max: Constants.defaults.game.maxPartyMembers+2})
    monsters = []

    (monsters.push (@generateScalableMonster party, party.score()*chance.floating({min: 1.2, max: 1.75}))) for x in [1..monsterCount]

    new Party @game, monsters if monsters.length > 0

module.exports = exports = MonsterGenerator
