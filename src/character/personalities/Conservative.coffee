
Personality = require "../base/Personality"

class Conservative extends Personality
  constructor: ->

  physicalAttackChance: -> 40

  @canUse = (player) ->
    player.statistics["combat self skill use"] >= 1000

module.exports = exports = Conservative