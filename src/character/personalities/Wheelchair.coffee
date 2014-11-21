
Personality = require "../base/Personality"

###*
  * This personality makes it so you are less likely to go up stairs, and slightly less likely to go down stairs.
  *
  * @name Wheelchair
  * @prerequisite Descend 5 staircases
  * @effect -200% chance to go up stairs
  * @effect -40% chance to go down stairs
  * @category Personalities
  * @package Player
###
class Wheelchair extends Personality

  constructor: ->

  descendChance: -> -40
  ascendChance: -> -200

  @canUse = (player) ->
    player.statistics["explore transfer descend"] >= 5

  @desc = "Descend 5 staircases"

module.exports = exports = Wheelchair
