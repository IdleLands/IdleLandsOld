
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

  @desc = "Player is in legal drinking age."

module.exports = exports = Drunk