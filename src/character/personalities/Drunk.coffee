
Personality = require "../base/Personality"

`/**
  * This personality makes you move more erratically, and act generally silly.
  *
  * @name Drunk
  * @prerequisite Become level 18
  * @effect -100 fleePercent
  * @effect -10% INT
  * @effect -10% WIS
  * @effect +10% STR
  * @effect +5% CON
  * @effect +5% AGI
  * @category Personalities
  * @package Player
*/`
class Drunk extends Personality
  constructor: ->

  fleePercent: -> -100
  
  intPercent: -> -10
  wisPercent: -> -10

  strPercent: -> 10
  conPercent: -> 5
  agiPercent: -> 5

  @canUse = (player) ->
    player.level.getValue() >= 18

  @desc = "Become level 18"

module.exports = exports = Drunk
