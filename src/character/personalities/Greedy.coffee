
Personality = require "../base/Personality"

###*
  * This personality makes it so you both gain and lose more gold, at the cost of XP.
  *
  * @name Greedy
  * @prerequisite Gain gold 10000 times
  * @effect +15% gold
  * @effect -15% xp
  * @category Personalities
  * @package Player
###
class Greedy extends Personality
  constructor: ->

  goldPercent: -> 15
  xpPercent: -> -15

  @canUse = (player) ->
    player.statistics["player gold gain"] >= 10000

  @desc = "Gain gold 10000 times"

module.exports = exports = Greedy
