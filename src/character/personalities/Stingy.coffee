
Personality = require "../base/Personality"

class Stingy extends Personality
  constructor: ->

  itemReplaceChancePercent: -> -100

  @canUse = (player) ->
    player.statistics["event findItem"] > 100

module.exports = exports = Stingy