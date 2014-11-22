
Personality = require "../base/Personality"

`/**
  * This personality makes you less likely to get into combat.
  *
  * @name Dove
  * @prerequisite Enter 10 battles
  * @effect Less likely to get into battles
  * @category Personalities
  * @package Player
*/`
class Dove extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type is "battle" then -300

  @canUse = (player) ->
    player.statistics["combat battle start"] >= 10

  @desc = "Enter 10 battles"

module.exports = exports = Dove