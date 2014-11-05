
Personality = require "../base/Personality"

class Chaotic extends Personality
  constructor: ->

  alignment: -> -10

  @canUse = (player) ->
    hoursPlayed = (Math.abs player.registrationDate.getTime()-Date.now()) / 36e5
    hoursPlayed >= (7 * 24)

  @desc = "Play for 1 week"

module.exports = exports = Chaotic
