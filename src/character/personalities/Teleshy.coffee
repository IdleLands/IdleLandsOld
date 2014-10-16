
Personality = require "../base/Personality"

class Teleshy extends Personality

  constructor: ->

  teleportChance: -> -100

  @canUse = (player) ->
    player.statistics["explore transfer teleport"] >= 50

  @desc = "Step through 50 portals"

module.exports = exports = Teleshy