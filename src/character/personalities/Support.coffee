
Personality = require "../base/Personality"

class Support extends Personality
  constructor: ->

  classChangePercent: (potential) ->
    -100 if not (@isSupport potential)

  @canUse = (player) ->
    player.statistics["combat self skill duration begin"] >= 100

  @desc = "Use 100 duration spells"

module.exports = exports = Support