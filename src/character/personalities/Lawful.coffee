
Personality = require "../base/Personality"

###*
  * This personality makes you Lawful-aligned.
  *
  * @name Lawful
  * @prerequisite Play for one week
  * @effect +10 alignment
  * @category Personalities
  * @package Player
###
class Lawful extends Personality
  constructor: ->

  alignment: -> 10

  @canUse = (player) ->
    hoursPlayed = (Math.abs player.registrationDate.getTime()-Date.now()) / 36e5
    hoursPlayed >= (7 * 24)

  @desc = "Play for 1 week"

module.exports = exports = Lawful
