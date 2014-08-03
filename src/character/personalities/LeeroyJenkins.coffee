
Personality = require "../base/Personality"

class LeeroyJenkins extends Personality
  constructor: ->

  intPercent: -> -20
  wisPercent: -> -20

  strPercent: -> 20
  agiPercent: -> 20

  @canUse = (player) ->
    player.statistics["battle start"] > 1000

module.exports = exports = LeeroyJenkins