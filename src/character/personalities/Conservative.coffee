
Personality = require "../base/Personality"

###*
  * This personality makes you use skills far less.
  *
  * @name Conservative
  * @prerequisite Use 150 combat skills
  * @effect +40% physical attack chance
  * @category Personalities
  * @package Player
###
class Conservative extends Personality
  constructor: ->

  physicalAttackChance: -> 40

  @canUse = (player) ->
    player.statistics["combat self skill use"] >= 150

  @desc = "Use 150 combat skills"

module.exports = exports = Conservative