
Personality = require "../base/Personality"

###*
  * This personality makes it so you are more likely to get into monster battles.
  *
  * @name Warmonger
  * @prerequisite Enter 10 battles
  * @category Personalities
  * @package Player
###
class Warmonger extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type is "battle" then 150

  @canUse = (player) ->
    player.statistics["combat battle start"] >= 10

  @desc = "Enter 10 battles"

module.exports = exports = Warmonger