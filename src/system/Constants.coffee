
_ = require "lodash"
Chance = require "chance"
chance = new Chance()

config = require "../../config/game.json"

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
    magical: ['Mage', 'Cleric', 'Bard', 'SandwichArtist', 'Bitomancer', 'MagicalMonster']
    support: ['Bard', 'SandwichArtist', 'Generalist']
    medic: ['Cleric', 'SandwichArtist']
    tank: ['Fighter', 'Barbarian', 'Pirate']
    dps: ['Mage', 'Rogue', 'Bitomancer', 'Archer']

  @pickRandomNormalEvent = (player) ->
    if player.party
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

module.exports = exports = Constants