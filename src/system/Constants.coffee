
_ = require "underscore"
Chance = require "chance"
chance = new Chance()

config = (require "../../config.json").gameConstants

class Constants
  @gameName = config.gameName
  @eventRates = config.eventRates
  @eventEffects = config.eventEffects
  @globalEventTimers = config.globalEventTimers
  @defaults = config.defaults

  @pickRandomNormalEvent = ->
    _.sample @eventRates

  @pickRandomNormalEventType = ->
    @pickRandomNormalEvent().type

  @pickRandomEvent = (player) ->
    event = @pickRandomNormalEvent()
    eventMod = player.personalityReduce 'eventModifier', [event], 0
    prob = (chance.integer {min: 0, max: event.max})
    return event.type if prob <= (event.min+eventMod+player.calc.stat 'luck')
    null

  @pickRandomGlobalEventType = ->
    _.sample @globalEventTimers

  @pickRandomGlobalEvent = ->
    @pickRandomGlobalEventType().type

module.exports = exports = Constants