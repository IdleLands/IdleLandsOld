
Personality = require "../base/Personality"

class Hasty extends Personality
  constructor: ->

  haste: -> 2
  offense: -> -2
  defense: -> -2

  @canUse = (player) ->
    hoursPlayed = (Math.abs player.registrationDate-(new Date())) / 60 * 60 * 1000
    hoursPlayed >= 2

  @desc = "Play for 2 hours"

module.exports = exports = Hasty
