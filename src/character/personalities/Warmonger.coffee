
Personality = require "../base/Personality"

class Warmonger extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type is "battle" then 1000

  @canUse = (player) ->
    player.statistics["combat battle start"] >= 10

  @desc = "Enter 10 battles"

module.exports = exports = Warmonger