
Personality = require "../base/Personality"

`/**
  * This personality makes it so you never change items. You become more susceptible to switcheroos, though.
  *
  * @name Stingy
  * @prerequisite Equip 100 items
  * @effect -100 itemReplaceChancePercent
  * @category Personalities
  * @package Player
*/`
class Stingy extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type is "flipStat" then 25

  itemReplaceChancePercent: -> -100

  @canUse = (player) ->
    player.statistics["event findItem"] >= 100

  @desc = "Equip 100 items"

module.exports = exports = Stingy