
Personality = require "../base/Personality"

class Clingy extends Personality
  constructor: ->

  partyLeavePercent: -> -100

  @canUse = (player) ->
    player.statistics["player party join"] >= 250

  @desc = "Join 250 parties"

module.exports = exports = Clingy