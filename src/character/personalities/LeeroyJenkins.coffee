
Personality = require "../base/Personality"

class LeeroyJenkins extends Personality
  constructor: ->

  intPercent: -> -20
  wisPercent: -> -20

  strPercent: -> 20
  agiPercent: -> 20

  @canUse = (player) ->
    player.statistics["combat battle start"] >= 250

  @desc = "Enter 250 battles"

module.exports = exports = LeeroyJenkins