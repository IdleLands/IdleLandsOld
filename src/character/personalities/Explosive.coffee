
Personality = require "../base/Personality"

class Explosive extends Personality
  constructor: ->

  physicalAttackChance: -> -50

  @canUse = (player) ->
    player.statistics["combat self skill use"] >= 175

  @desc = "Use 175 combat skills"

module.exports = exports = Explosive