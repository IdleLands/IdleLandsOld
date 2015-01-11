
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "lodash"

`/**
  * This achievement is achieved by achieving achievements.
  *
  * @name Achievable
  * @prerequisite Achieve 50*n achievements.
  * @reward +1 achievement
  * @category Achievements
  * @package Player
*/`
class Achievable extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player._oldAchievements?.length or 0

    currentCheckValue = 50
    killInterval = 50
    achieved = []

    while baseStat >= currentCheckValue
      level = currentCheckValue / killInterval
      item =
        name: "Achievable #{toRoman level}"
        desc: "Achieve #{currentCheckValue} achievements"
        reward: "+1 achievement"
        type: "progress"

      item.title = "Achiever" if level is 5

      achieved.push item

      currentCheckValue += killInterval

    achieved


module.exports = exports = Achievable
