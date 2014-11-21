
Personality = require "../base/Personality"

###*
  * This personality makes you move faster around the world, at the cost of combat statistics.
  *
  * @name Hasty
  * @prerequisite Play for 2 hours
  * @effect +2 haste
  * @effect -2 offense
  * @effect -2 defense
  * @category Personalities
  * @package Player
###
class Hasty extends Personality
  constructor: ->

  haste: -> 2
  offense: -> -2
  defense: -> -2

  @canUse = (player) ->
    hoursPlayed = (Math.abs player.registrationDate.getTime()-Date.now()) / 36e5
    hoursPlayed >= 2

  @desc = "Play for 2 hours"

module.exports = exports = Hasty
