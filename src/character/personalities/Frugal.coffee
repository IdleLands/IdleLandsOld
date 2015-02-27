
Personality = require "../base/Personality"

`/**
  * This personality decreases the probability of merchant events, but items cost less when a merchant does shop up. Thrifty!
  *
  * @name Frugal
  * @prerequisite Receive 15 merchant events
  * @effect -25% merchant event item costs
  * @effect lower merchant event probability
  * @category Personalities
  * @package Player
*/`
class Frugal extends Personality
  constructor: ->

  shopPercent: -> -25

  eventModifier: (player, event) -> if event.type is "merchant" then -100

  @canUse = (player) ->
    player.statistics["event merchant"] >= 15

  @desc = "Receive 15 merchant events"

module.exports = exports = Frugal