
Personality = require "../base/Personality"

class Wheelchair extends Personality

  constructor: ->

  descendChance: -> -100
  ascendChance: -> 100

  @canUse = (player) ->
    player.statistics["explore transfer ascend"] >= 5

module.exports = exports = Wheelchair