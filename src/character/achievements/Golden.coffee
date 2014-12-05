
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

`/**
  * This achievement is earned by gaining and losing a lot of gold.
  *
  * @name Golden
  * @prerequisite Gain and lose 20000*[10*[n-1]+1] total gold.
  * @reward +[achievementLevel*0.03] itemSellMultiplier
  * @category Achievements
  * @package Player
*/`
class Golden extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['calculated total gold gained'] + player.statistics['calculated total gold lost']

    currentCheckValue = 20000
    multiplier = 10
    level = 1
    achieved = []

    while baseStat >= currentCheckValue
      achieved.push
        name: "Golden #{toRoman level}"
        desc: "Gain and lose #{currentCheckValue} total gold"
        reward: "+#{(level*0.03).toFixed 1} itemSellMultiplier"
        itemSellMultiplier: -> level*0.03
        type: "event"

      currentCheckValue *= multiplier
      level++

    achieved


module.exports = exports = Golden