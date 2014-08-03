
Personality = require "../base/Personality"

class Pacifist extends Personality
  constructor: ->

  fleePercent: -> 100

  @canUse = (player) ->
    player.statistics["combat self flee"] > 0

module.exports = exports = Pacifist