
Personality = require "../base/Personality"

class TreasureHunter extends Personality
  constructor: ->

  xpPercent: -> -20

  goldPercent: -> -20

  itemFindRangeMultiplier: -> level*0.2

  @canUse = (player) ->
    player.statistics["event sellItem"] > 1000

  @desc = "Sell items 1000 times"

module.exports = exports = TreasureHunter