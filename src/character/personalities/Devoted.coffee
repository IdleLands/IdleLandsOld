
Personality = require "../base/Personality"

class Devoted extends Personality
  constructor: ->

  classChangePercent: (potential) ->
    -100

  @canUse = (player) ->
    player.statistics["player trainer speak"] > 10

module.exports = exports = Devoted