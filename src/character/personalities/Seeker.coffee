
Personality = require "../base/Personality"

class Seeker extends Personality
  constructor: ->

  goldPercent: -> -15
  xpPercent: -> 15

  @canUse = (player) ->
    player.statistics["player xp gain"] >= 100000

  @desc = "Gain XP 100000 times"

module.exports = exports = Seeker
