
Personality = require "../base/Personality"

###*
  * This personality makes it so you find more, powerful items.
  *
  * @name TreasureHunter
  * @prerequisite Sell 1000 items
  * @effect -50% xp
  * @effect -50% gold
  * @effect +[level/20] itemFindRangeMultiplier
  * @category Personalities
  * @package Player
###
class TreasureHunter extends Personality
  constructor: ->

  xpPercent: -> -50

  goldPercent: -> -50

  itemFindRangeMultiplier: (player) -> player.level.getValue()*0.05

  @canUse = (player) ->
    player.statistics["player sellItem"] >= 1000

  @desc = "Sell 1000 items"

module.exports = exports = TreasureHunter
