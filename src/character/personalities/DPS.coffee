
Personality = require "../base/Personality"

class DPS extends Personality
  constructor: ->

  classChangePercent: (potential) ->
    -100 if not Personality::isDPS potential

  @canUse = (player) ->
    player.statistics["calculated total damage given"] >= 500000

  @desc = "Deal 500000 damage"

module.exports = exports = DPS