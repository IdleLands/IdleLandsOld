
Personality = require "../base/Personality"
Constants = require "../../system/utilities/Constants"

`/**
  * This personality makes you never change classes, unless the resulting class is considered DPS.
  *
  * @name DPS
  * @prerequisite Deal 500000 damage
  * @effect +4% INT
  * @effect +4% STR
  * @effect -5% CON
  * @effect -5% WIS
  * @category Personalities
  * @package Player
*/`

class DPS extends Personality
  constructor: ->

  intPercent: -> 4
  strPercent: -> 4
  conPercent: -> -5
  wisPercent: -> -5

  classChangePercent: (potential) ->
    -100 if not Constants.isDPS potential

  @canUse = (player) ->
    player.statistics["calculated total damage given"] >= 500000

  @desc = "Deal 500000 damage"

module.exports = exports = DPS