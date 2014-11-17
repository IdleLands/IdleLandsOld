
Personality = require "../base/Personality"

class Medic extends Personality
  constructor: ->

  classChangePercent: (potential) ->
    -100 if not Personality.isMedic potential

  @canUse = (player) ->
    player.statistics["calculated total heals given"] >= 50000

  @desc = "Heal 50000 damage"

module.exports = exports = Medic