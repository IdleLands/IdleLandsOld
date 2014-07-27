
Personality = require "../base/Personality"

class Overkiller extends Personality
  constructor: ->

  @canUse = (player) ->
    player.statistics["max damage"] > 5000

module.exports = exports = Overkiller