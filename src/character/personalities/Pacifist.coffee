
Personality = require "../base/Personality"

###*
  * This personality makes you very likely to flee combat.
  *
  * @name Pacifist
  * @prerequisite Flee combat once
  * @effect +100 fleePercent
  * @effect +5% xp
  * @category Personalities
  * @package Player
###
class Pacifist extends Personality
  constructor: ->

  fleePercent: -> 100

  xpPercent: -> 5

  @canUse = (player) ->
    player.statistics["combat self flee"] > 0

  @desc = "Flee combat once"

module.exports = exports = Pacifist