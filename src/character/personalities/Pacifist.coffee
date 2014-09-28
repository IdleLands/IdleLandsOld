
Personality = require "../base/Personality"

class Pacifist extends Personality
  constructor: ->

  fleePercent: -> 100

  xpPercent: -> 5

  @canUse = (player) ->
    player.statistics["combat self flee"] > 0

  @desc = "Flee combat once"

module.exports = exports = Pacifist