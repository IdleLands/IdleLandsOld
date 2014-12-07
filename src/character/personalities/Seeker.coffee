
Personality = require "../base/Personality"

`/**
  * This personality makes it so you both gain and lose more XP, at the cost of gold.
  *
  * @name Seeker
  * @prerequisite Gain xp 100000 times
  * @effect +15% xp
  * @effect -15% gold
  * @category Personalities
  * @package Player
*/`
class Seeker extends Personality
  constructor: ->

  goldPercent: -> -15
  xpPercent: -> 15

  @canUse = (player) ->
    player.statistics["player xp gain"] >= 100000

  @desc = "Gain XP 100000 times"

module.exports = exports = Seeker
