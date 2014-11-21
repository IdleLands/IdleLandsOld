
Personality = require "../base/Personality"

###*
  * This personality makes you never want to leave parties.
  *
  * @name Clingy
  * @prerequisite Join 250 parties
  * @effect -100 partyLeavePercent
  * @effect More likely to join parties
  * @category Personalities
  * @package Player
###
class Clingy extends Personality
  constructor: ->

  partyLeavePercent: -> -100

  eventModifier: (player, event) -> if event.type is "party" then 100

  @canUse = (player) ->
    player.statistics["player party join"] >= 250

  @desc = "Join 250 parties"

module.exports = exports = Clingy