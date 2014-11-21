
Personality = require "../base/Personality"

###*
  * This personality makes you charge into battle, like a famous WoW veteran.
  *
  * @name LeeroyJenkins
  * @prerequisite Enter combat 250 times
  * @effect -20% INT
  * @effect -20% WIS
  * @effect +20% STR
  * @effect +20% AGI
  * @category Personalities
  * @package Player
###
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