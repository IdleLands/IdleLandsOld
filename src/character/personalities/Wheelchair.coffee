
Personality = require "../base/Personality"

class Wheelchair extends Personality

  constructor: ->

  descendChance: -> -40
  ascendChance: -> -100

  @canUse = (player) ->
    player.statistics["explore transfer descend"] >= 5

  @desc = "Descend 5 staircases"

module.exports = exports = Wheelchair