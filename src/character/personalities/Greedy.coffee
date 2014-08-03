
Personality = require "../base/Personality"

class Greedy extends Personality
  constructor: ->

  goldPercent: -> 15
  xpPercent: -> -5

  @canUse = (player) ->
    player.statistics["player gold gain"] > 500

module.exports = exports = Greedy