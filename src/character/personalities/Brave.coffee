
Personality = require "../base/Personality"

###*
  * This personality attempts to prevent you from fleeing from combat.
  *
  * @name Brave
  * @prerequisite Flee combat once
  * @effect -100 fleePercent
  * @effect +5% STR
  * @effect +10% XP loss at end of combat
  * @category Personalities
  * @package Player
###
class Brave extends Personality
  constructor: ->

  fleePercent: -> -100

  strPercent: -> 5

  combatEndXpLoss: (player, baseCombatEndXpLoss) -> parseInt baseCombatEndXpLoss*0.1

  @canUse = (player) ->
    player.statistics["combat self flee"] > 0

  @desc = "Flee combat once"

module.exports = exports = Brave