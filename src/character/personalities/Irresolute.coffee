
Personality = require "../base/Personality"

`/**
  * This personality makes it so your boss rechallenge timer is 5 minutes instead of 60 seconds.
  *
  * @name Irresolute
  * @prerequisite Lose 10 boss fights
  * @category Personalities
  * @package Player
*/`
class Irresolute extends Personality
  constructor: ->

  bossRechallengeTime: -> 240

  @canUse = (player) ->
    player.statistics["event bossbattle lose"] >= 10

  @desc = "Lose 10 boss fights"

module.exports = exports = Irresolute