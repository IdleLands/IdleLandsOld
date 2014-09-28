
Personality = require "../base/Personality"

class Conservative extends Personality
  constructor: ->

  physicalAttackChance: -> 40

  @canUse = (player) ->
    player.statistics["combat self skill use"] >= 150

  @desc = "Use 150 combat skills"

module.exports = exports = Conservative