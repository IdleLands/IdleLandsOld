
Personality = require "../base/Personality"

`/**
  * This personality increases the probability of merchant events, and also makes it much more likely that you'll buy something.
  *
  * @name Shopaholic
  * @prerequisite Receive 3 merchant events
  * @effect higher merchant event probability
  * @effect more likely to buy items
  * @category Personalities
  * @package Player
*/`
class Shopaholic extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type is "merchant" then 250

  @canUse = (player) ->
    player.statistics["event merchant"] >= 3

  @desc = "Receive 3 merchant events"

module.exports = exports = Shopaholic