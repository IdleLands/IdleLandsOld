
Personality = require "../base/Personality"

`/**
  * This personality makes you more likely to leave parties.
  *
  * @name Impartial
  * @prerequisite Leave 250 parties
  * @effect +50 partyLeavePercent
  * @category Personalities
  * @package Player
*/`
class Impartial extends Personality
  constructor: ->

  partyLeavePercent: -> 50

  @canUse = (player) ->
    player.statistics["player party leave"] >= 250

  @desc = "Leave 250 parties"

module.exports = exports = Impartial