
Personality = require "../base/Personality"

class TreasureHunter extends Personality
  constructor: ->

  xpPercent: -> -50

  goldPercent: -> -50

  itemFindRangeMultiplier: (player) -> player.level.getValue()*0.05

  @canUse = (player) ->
    player.statistics["player sellItem"] >= 1000

  @desc = "Sell 1000 items"

module.exports = exports = TreasureHunter
