
Personality = require "../base/Personality"

class Impartial extends Personality
  constructor: ->

  partyLeavePercent: -> 50

  @canUse = (player) ->
    player.statistics["player party leave"] >= 250

  @desc = "Leave 250 parties"

module.exports = exports = Impartial