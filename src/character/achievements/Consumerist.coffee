
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

`/**
  * This achievement is earned by spending gold.
  *
  * @name Consumerist
  * @prerequisite Spend 100000*[3*[n-1]+1] total gold.
  * @reward +0.07 itemSellMultiplier
  * @category Achievements
  * @package Player
*/`
class Consumerist extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['calculated total gold spent']

    currentCheckValue = 100000
    multiplier = 3
    level = 1
    achieved = []

    while baseStat >= currentCheckValue
      item =
        name: "Consumerist #{toRoman level}"
        desc: "Spend #{currentCheckValue} total gold"
        reward: "+0.07 itemSellMultiplier"
        itemSellMultiplier: -> level*0.07
        type: "event"

      item.title = "Consumerist" if level is 5

      achieved.push item

      currentCheckValue *= multiplier
      level++

    achieved


module.exports = exports = Consumerist