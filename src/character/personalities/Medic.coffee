
Personality = require "../base/Personality"
Constants = require "../../system/Constants"

`/**
  * This personality makes you never change classes, unless the resulting class is considered Medic.
  *
  * @name Medic
  * @prerequisite Heal 50000 damage
  * @effect +5% WIS
  * @effect -3% AGI
  * @effect -3% DEX
  * @category Personalities
  * @package Player
*/`
class Medic extends Personality
  constructor: ->

  wisPercent: -> 5
  agiPercent: -> -3
  dexPercent: -> -3

  classChangePercent: (potential) ->
    -100 if not Constants.isMedic potential

  @canUse = (player) ->
    player.statistics["calculated total heals given"] >= 50000

  @desc = "Heal 50000 damage"

module.exports = exports = Medic