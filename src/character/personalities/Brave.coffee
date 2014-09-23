
Personality = require "../base/Personality"

class Brave extends Personality
  constructor: ->

  fleePercent: -> -100
  combatEndXpLoss: -> 10

  @canUse = (player) ->
    player.statistics["combat self flee"] > 0

module.exports = exports = Brave
