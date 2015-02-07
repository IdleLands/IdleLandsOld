
Personality = require "../base/Personality"

`/**
  * This personality makes it so you see very few advertisements, if at all.
  *
  * @name Earplugs
  * @prerequisite Receive 10 advertisements
  * @category Personalities
  * @package Player
*/`
class Earplugs extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type is "advertisement" then -500

  @canUse = (player) ->
    player.statistics["event advertisement"] >= 10

  @desc = "Receive 10 advertisements"

module.exports = exports = Earplugs