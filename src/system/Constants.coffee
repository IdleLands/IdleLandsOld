
_ = require "underscore"
Chance = require "chance"
chance = new Chance()

config = (require "../../config.json").gameConstants

class Constants
  @gameName = config.gameName
  @eventRates = config.eventRates
  @eventEffects = config.eventEffects
  @defaults = config.defaults

  @pickRandomEventType = ->
    _.sample @eventRates

  @pickRandomEvent = (player) ->
    event = @pickRandomEventType()
    eventMod = player.personalityReduce 'eventModifier', [event], 0
    prob = chance.integer {min: 0, max: event.max}
    return event.type if prob <= (event.min+eventMod)
    null

module.exports = exports = Constants