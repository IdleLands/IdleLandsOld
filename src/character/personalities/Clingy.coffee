
Personality = require "../base/Personality"

class Clingy extends Personality
  constructor: ->

  partyLeavePercent: -> -100

  @canUse = (player) ->
    player.statistics["player party join"] > 500

module.exports = exports = Clingy