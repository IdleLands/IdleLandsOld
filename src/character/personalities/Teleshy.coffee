
Personality = require "../base/Personality"

###*
  * This personality makes it so you are less likely to use teleports.
  *
  * @name Teleshy
  * @prerequisite Teleport 50 times
  * @effect -99% chance to use a teleport
  * @category Personalities
  * @package Player
###
class Teleshy extends Personality

  constructor: ->

  teleportChance: -> -99

  @canUse = (player) ->
    player.statistics["explore transfer teleport"] >= 50

  @desc = "Step through 50 portals"

module.exports = exports = Teleshy