
Personality = require "../base/Personality"

###*
  * This personality makes you Evil-aligned.
  *
  * @name Evil
  * @prerequisite None
  * @effect -5 alignment
  * @category Personalities
  * @package Player
###
class Evil extends Personality
  constructor: ->

  alignment: -> -5

  @canUse = -> yes

  @desc = "No prerequisite"

module.exports = exports = Evil