
Personality = require "../base/Personality"

###*
  * This personality makes you never change classes.
  *
  * @name Devoted
  * @prerequisite Change classes 10 times
  * @effect +5% STR
  * @effect +5% DEX
  * @effect +5% CON
  * @effect +5% AGI
  * @effect +5% INT
  * @effect +5% WIS
  * @category Personalities
  * @package Player
###
class Devoted extends Personality
  constructor: ->

  strPercent: -> 5
  dexPercent: -> 5
  agiPercent: -> 5
  conPercent: -> 5
  wisPercent: -> 5
  intPercent: -> 5

  classChangePercent: (potential) ->
    -100

  @canUse = (player) ->
    player.statistics["player profession change"] >= 10

  @desc = "Change class 10 times"

module.exports = exports = Devoted
