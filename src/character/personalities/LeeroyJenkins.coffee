
Personality = require "../base/Personality"

class LeeroyJenkins extends Personality
  constructor: ->

  intPercent: -> -10
  wisPercent: -> -10

  strPercent: -> 10
  agiPercent: -> 10

  @canUse = (player) ->
    player.statistics["battle start"] > 1000

module.exports = exports = LeeroyJenkins