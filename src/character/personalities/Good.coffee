
Personality = require "../base/Personality"

`/**
  * This personality makes you Good-aligned.
  *
  * @name Good
  * @prerequisite None
  * @effect +5 alignment
  * @category Personalities
  * @package Player
*/`
class Good extends Personality
  constructor: ->

  alignment: -> 5

  @canUse = -> yes

  @desc = "No prerequisite"

module.exports = exports = Good