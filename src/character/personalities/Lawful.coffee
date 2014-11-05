
Personality = require "../base/Personality"

class Lawful extends Personality
  constructor: ->

  alignment: -> 10

  @canUse = (player) ->
    daysPlayed = (Math.abs player.registrationDate-(new Date())) / 24 * 36e5
    daysPlayed >= 7

  @desc = "Play for 1 week"

module.exports = exports = Lawful
