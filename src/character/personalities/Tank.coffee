
Personality = require "../base/Personality"

###*
  * This personality makes you never change classes, unless the resulting class is considered Tank.
  *
  * @name Tank
  * @prerequisite Receive 200000 damage
  * @category Personalities
  * @package Player
###
class Tank extends Personality
  constructor: ->

  classChangePercent: (potential) ->
    -100 if not Personality.isTank potential

  @canUse = (player) ->
    player.statistics["calculated total damage received"] >= 200000

  @desc = "Receive 200000 damage"

module.exports = exports = Tank
