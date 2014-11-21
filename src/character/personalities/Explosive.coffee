
Personality = require "../base/Personality"

###*
  * This personality makes you more likely to use skills. For some classes, this means they will always use skills until
  * they run out of casting capability.
  *
  * @name Explosive
  * @prerequisite Use 175 skills
  * @effect -50% physical attack chance
  * @category Personalities
  * @package Player
###
class Explosive extends Personality
  constructor: ->

  physicalAttackChance: -> -50

  @canUse = (player) ->
    player.statistics["combat self skill use"] >= 175

  @desc = "Use 175 combat skills"

module.exports = exports = Explosive