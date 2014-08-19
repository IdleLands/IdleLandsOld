
Personality = require "../base/Personality"

class Greedy extends Personality
  constructor: ->

  goldPercent: -> 15
  xpPercent: -> -15

  @canUse = (player) ->
    player.statistics["player gold gain"] > 25000

module.exports = exports = Greedy
