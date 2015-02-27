
_ = require "lodash"
Chance = require "chance"
chance = new Chance()

config = require "../../../config/game.json"
_.extend config, require "../../../config/events.json"

class Constants
  @gameName = config.gameName
  @eventRates = config.eventRates
  @eventEffects = config.eventEffects
  @globalEventTimers = config.globalEventTimers
  @defaults = config.defaults

  @isPhysical = (test) ->
    test in @classCategorization.physical

  @isMagical = (test) ->
    test in @classCategorization.magical

  @isMedic = (test) ->
    test in @classCategorization.medic

  @isDPS = (test) ->
    test in @classCategorization.dps

  @isTank = (test) ->
    test in @classCategorization.tank

  @isSupport = (test) ->
    test in @classCategorization.support

  @classCategorization =
    physical: ['Fighter', 'Generalist', 'Barbarian', 'Rogue', 'Jester', 'Pirate', 'Monster', 'Archer']
    magical: ['Mage', 'Cleric', 'Bard', 'SandwichArtist', 'Bitomancer', 'MagicalMonster', 'Necromancer']
    support: ['Bard', 'SandwichArtist', 'Generalist']
    medic: ['Cleric', 'SandwichArtist']
    tank: ['Fighter', 'Barbarian', 'Pirate']
    dps: ['Mage', 'Rogue', 'Bitomancer', 'Archer', 'Necromancer']

  @pickRandomNormalEvent = (player) ->
    if player?.party
      _.sample @eventRates
    else
      _.sample (_.reject @eventRates, (event) -> event.party?)

  @pickRandomNormalEventType = (player) ->
    @pickRandomNormalEvent(player).type

  @pickRandomEvent = (player) ->
    event = @pickRandomNormalEvent player
    eventMod = player.calc.eventModifier event
    prob = (chance.integer {min: 0, max: event.max})
    return event.type if prob <= (event.min+eventMod+(Math.max 1, player.calc.luckBonus()))
    null

  @pickRandomGlobalEventType = ->
    _.sample @globalEventTimers

  @pickRandomGlobalEvent = ->
    @pickRandomGlobalEventType().type

  @gidMap =
    1: "StairsDown"
    2: "StairsUp"
    3: "BrickWall"
    4: "Grass"
    5: "Water"
    6: "Lava"
    7: "Tile"
    8: "Ice"
    9: "Forest"
    10: "Sand"
    11: "Swamp"
    12: "BlueNPC"
    13: "RedNPC"
    14: "GreenNPC"
    15: "QuestionMark"
    16: "Tree"
    17: "Mountain"
    18: "Door"
    19: "Dirt"
    20: "FighterTrainer"
    21: "MageTrainer"
    22: "ClericTrainer"
    23: "JesterTrainer"
    24: "RogueTrainer"
    25: "GeneralistTrainer"
    26: "Boss"
    27: "Chest"
    28: "PurpleTeleport"
    29: "RedTeleport"
    30: "YellowTeleport"
    31: "GreenTeleport"
    32: "BlueTeleport"
    33: "Cloud"
    34: "Wood"
    35: "Hole"
    36: "Gravel"
    37: "Mushroom"
    38: "StoneWall"
    39: "Box"
    40: "LadderUp"
    41: "LadderDown"
    42: "RopeUp"
    43: "RopeDown"
    44: "Table"
    45: "Pot"
    46: "Barrel"
    47: "Bed"
    48: "Sign"
    49: "Carpet"
    50: "CrumblingBrick"
    51: "Skeleton"
    52: "Snow"
    53: "Fence"
    54: "Dead Tree"
    55: "Palm Tree"

  @revGidMap = _.invert @gidMap

module.exports = exports = Constants