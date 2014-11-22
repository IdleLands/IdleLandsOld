
Personality = require "../base/Personality"

`/**
  * This personality does nothing.
  *
  * @name Overkiller
  * @prerequisite Deal 5000 damage in one hit
  * @category Personalities
  * @package Player
*/`
class Overkiller extends Personality
  constructor: ->

  @canUse = (player) ->
    player.statistics["calculated max damage given"] > 5000

  @desc = "Deal 5000 damage in one hit"

module.exports = exports = Overkiller
