
Personality = require "../base/Personality"

class Brave extends Personality
  constructor: ->

  fleePercent: -> -100

  strPercent: -> 5

  combatEndXpLoss: (player, baseCombatEndXpLoss) -> parseInt baseCombatEndXpLoss*0.1

  @canUse = (player) ->
    player.statistics["combat self flee"] > 0

  @desc = "Flee combat once"

module.exports = exports = Brave