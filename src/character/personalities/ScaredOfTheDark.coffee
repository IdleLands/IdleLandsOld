
Personality = require "../base/Personality"

###*
  * This personality makes you scared of the dark. Scaredy cat.
  *
  * @name ScaredOfTheDark
  * @prerequisite Ascend 5 staircases
  * @effect -100% chance to go down stairs
  * @effect +100% chance to go up stairs
  * @category Personalities
  * @package Player
###
class ScaredOfTheDark extends Personality

  constructor: ->

  descendChance: -> -100
  ascendChance: -> 100

  @canUse = (player) ->
    player.statistics["explore transfer ascend"] >= 5

  @desc = "Ascend 5 staircases"

module.exports = exports = ScaredOfTheDark