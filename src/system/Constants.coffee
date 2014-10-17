
_ = require "underscore"
Chance = require "chance"
chance = new Chance()

config = require "../../config/game.json"

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
    eventMod = player.calc.eventModifier event
    prob = (chance.integer {min: 0, max: event.max})
    return event.type if prob <= (event.min+eventMod+(Math.max 1, player.calc.luckBonus()))
    null

  @pickRandomGlobalEventType = ->
    _.sample @globalEventTimers

  @pickRandomGlobalEvent = ->
    @pickRandomGlobalEventType().type

module.exports = exports = Constants