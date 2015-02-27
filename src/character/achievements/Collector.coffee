
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "lodash"

`/**
  * This achievement is earned by finding many little collectibles scattered throughout the world.
  *
  * @name Collector
  * @prerequisite Find 25*[2^n] collectibles
  * @reward +1% STR
  * @reward +1% DEX
  * @reward +1% AGI
  * @reward +1% CON
  * @reward +1% WIS
  * @reward +1% INT
  * @reward +1 inventory slot (This only applies once for every 3 levels of Collector.)
  * @category Achievements
  * @package Player
*/`
class Collector extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.collectibles?.length or 0

    currentCheckValue = 25
    levelInterval = 2
    level = 1
    achieved = []

    while baseStat >= currentCheckValue
      item =
        name: "Collector #{toRoman level}"
        desc: "Find #{currentCheckValue} unique collectibles"
        reward: "+1% STR/DEX/AGI/CON/WIS/INT"
        type: "exploration"

      item.title = "Collector" if level is 5

      if level%%3 is 0
        item.inventorySize = -> 1

      achieved.push item

      currentCheckValue *= levelInterval
      level++

    achieved


module.exports = exports = Collector