
Personality = require "../base/Personality"

`/**
  * This personality makes you Chaotic-aligned.
  *
  * @name Chaotic
  * @prerequisite Play for one week
  * @effect -10 alignment
  * @category Personalities
  * @package Player
*/`
class Chaotic extends Personality
  constructor: ->

  alignment: -> -10

  @canUse = (player) ->
    hoursPlayed = (Math.abs player.registrationDate.getTime()-Date.now()) / 36e5
    hoursPlayed >= (7 * 24)

  @desc = "Play for 1 week"

module.exports = exports = Chaotic
