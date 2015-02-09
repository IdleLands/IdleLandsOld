
Personality = require "../base/Personality"

`/**
  * This personality makes it so you see very few town crier events, if at all.
  *
  * @name Earplugs
  * @prerequisite Receive 10 town crier events
  * @category Personalities
  * @package Player
*/`
class Earplugs extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type is "towncrier" then -500

  @canUse = (player) ->
    player.statistics["event towncrier"] >= 10

  @desc = "Receive 10 town crier events"

module.exports = exports = Earplugs