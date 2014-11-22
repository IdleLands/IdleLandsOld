
Personality = require "../base/Personality"

`/**
  * This personality makes you never change classes, unless the resulting class is considered DPS.
  *
  * @name DPS
  * @prerequisite Deal 500000 damage
  * @category Personalities
  * @package Player
*/`
class DPS extends Personality
  constructor: ->

  classChangePercent: (potential) ->
    -100 if not Personality.isDPS potential

  @canUse = (player) ->
    player.statistics["calculated total damage given"] >= 500000

  @desc = "Deal 500000 damage"

module.exports = exports = DPS