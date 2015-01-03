
Personality = require "../base/Personality"

`/**
  * This personality makes you never have events happen. In general.
  *
  * @name Sanctified
  * @prerequisite Find a sacred item
  * @effect event probability drastically reduced
  * @category Personalities
  * @package Player
*/`
class Sanctified extends Personality
  constructor: ->

  eventModifier: -> -10000

  @canUse = (player) ->
    player.permanentAchievements?.hasFoundSacred

  @desc = "Find a sacred item"

module.exports = exports = Sanctified