
Personality = require "../base/Personality"

class Overkiller extends Personality
  constructor: ->

  @canUse = (player) ->
    player.statistics["max damage"] > 5000

  @desc = "Deal 5000 damage in one hit"

module.exports = exports = Overkiller