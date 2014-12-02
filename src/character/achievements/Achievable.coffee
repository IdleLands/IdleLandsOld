
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "underscore"

`/**
  * This achievement is achieved by achieving achievements.
  *
  * @name Achievable
  * @prerequisite Achieve 50*n achievements.
  * @reward +1 awesome
  * @category Achievements
  * @package Player
*/`
class Achievable extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.achievements?.length or 0

    currentCheckValue = 50
    killInterval = 50
    achieved = []

    while baseStat >= currentCheckValue
      level = currentCheckValue / killInterval
      item =
        name: "Achievable #{toRoman level}"
        desc: "Achievable #{currentCheckValue} achievements"
        reward: "+1 awesome"
        type: "progress"

      achieved.push item

      currentCheckValue += killInterval


module.exports = exports = Achievable