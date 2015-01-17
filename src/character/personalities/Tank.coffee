
Personality = require "../base/Personality"
Constants = require "../../system/utilities/Constants"

`/**
  * This personality makes you never change classes, unless the resulting class is considered Tank.
  *
  * @name Tank
  * @prerequisite Receive 200000 damage
  * @effect Slightly more likely to get into battles
  * @effect Slightly more likely to have items forsaken
  * @effect +5% CON
  * @effect -3% INT
  * @effect -3% WIS
  * @category Personalities
  * @package Player
*/`
class Tank extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type in ["battle", "forsakeItem"] then 100

  conPercent: -> 5
  intPercent: -> -3
  wisPercent: -> -3

  classChangePercent: (potential) ->
    -100 if not Constants.isTank potential

  @canUse = (player) ->
    player.statistics["calculated total damage received"] >= 200000

  @desc = "Receive 200000 damage"

module.exports = exports = Tank
