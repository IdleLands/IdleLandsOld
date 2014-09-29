
Personality = require "../base/Personality"

class Drunk extends Personality
  constructor: ->

  fleePercent: -> -100
  
  intPercent: -> -10
  wisPercent: -> -10

  strPercent: -> 10
  conPercent: -> 5
  agiPercent: -> 5

  @canUse = (player) ->
    player.level.getValue() >= 18

  @desc = "Become level 18"

module.exports = exports = Drunk
