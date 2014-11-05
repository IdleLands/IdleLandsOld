
Personality = require "../base/Personality"

class Devoted extends Personality
  constructor: ->

  strPercent: -> 5
  dexPercent: -> 5
  agiPercent: -> 5
  conPercent: -> 5
  wisPercent: -> 5
  intPercent: -> 5

  classChangePercent: (potential) ->
    -100

  @canUse = (player) ->
    player.statistics["player profession change"] >= 10

  @desc = "Change class 10 times"

module.exports = exports = Devoted
