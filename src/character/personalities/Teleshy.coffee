
Personality = require "../base/Personality"

class Teleshy extends Personality

  constructor: ->

  teleportChance: -> -100

  @canUse = (player) ->
    player.statistics["explore transfer teleport"] >= 5

module.exports = exports = Teleshy