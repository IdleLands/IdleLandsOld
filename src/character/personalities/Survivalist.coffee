
Personality = require "../base/Personality"

class Survivalist extends Personality
  constructor: ->

  fleePercent: (player) -> if player.hp.ltePercent 10 then 80 else 0

  xpPercent: -> -10

  @canUse = (player) ->
    player.statistics["event cataclysms"] >= 25

  @desc = "Experience 25 cataclysms"

module.exports = exports = Survivalist