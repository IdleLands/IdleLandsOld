
Personality = require "../base/Personality"

class Tank extends Personality
  constructor: ->

  classChangePercent: (potential) ->
    -100 if not (@isTank potential)

  @canUse = (player) ->
    player.statistics["calculated damage received"] >= 200000

  @desc = "Receive 200000 damage"

module.exports = exports = Tank