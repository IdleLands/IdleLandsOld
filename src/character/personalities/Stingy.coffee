
Personality = require "../base/Personality"

class Stingy extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type is "flipStat" then 25

  itemReplaceChancePercent: -> -100

  @canUse = (player) ->
    player.statistics["event findItem"] >= 100

  @desc = "Equip 100 items"

module.exports = exports = Stingy