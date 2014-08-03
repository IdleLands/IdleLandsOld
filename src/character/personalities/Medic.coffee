
Personality = require "../base/Personality"

class Medic extends Personality
  constructor: ->

  classChangePercent: (potential) ->
    -100 if not (@isMedic potential)

  @canUse = (player) ->
    player.statistics["player trainer speak"] > 10

module.exports = exports = Medic