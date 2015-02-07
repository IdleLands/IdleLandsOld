
Personality = require "../base/Personality"

`/**
  * This personality increases the probability of seeing random town crier events.
  *
  * @name Adophile
  * @prerequisite Receive 10 town crier events
  * @category Personalities
  * @package Player
*/`
class Adophile extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type is "towncrier" then -500

  @canUse = (player) ->
    player.statistics["event towncrier"] >= 10

  @desc = "Receive 10 town crier events"

module.exports = exports = Adophile