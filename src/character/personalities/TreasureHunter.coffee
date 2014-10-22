
Personality = require "../base/Personality"

class TreasureHunter extends Personality
  constructor: ->

  xpPercent: -> -20

  goldPercent: -> -20

  itemFindRangeMultiplier: -> level*0.2

  @canUse = (player) ->
    player.statistics["player sellItem"] >= 1000

  @desc = "Sell 1000 items"

module.exports = exports = TreasureHunter
