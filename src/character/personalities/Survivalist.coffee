
Personality = require "../base/Personality"

`/**
  * This personality makes you attempt to flee combat at lower hp values.
  *
  * @name Survivalist
  * @prerequisite Experience 25 cataclysms
  * @effect -10% xp
  * @effect Flee when hp <= 10%
  * @category Personalities
  * @package Player
*/`
class Survivalist extends Personality
  constructor: ->

  fleePercent: (player) -> if player.hp.ltePercent 10 then 80 else 0

  xpPercent: -> -10

  @canUse = (player) ->
    player.statistics["event cataclysms"] >= 25

  @desc = "Experience 25 cataclysms"

module.exports = exports = Survivalist