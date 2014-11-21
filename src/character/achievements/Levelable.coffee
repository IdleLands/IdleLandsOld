
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

###*
  * This achievement is earned by achieving certain levels.
  *
  * @name Levelable
  * @prerequisite Become level 5*[5*[n-1]+1].
  * @reward +1 LUCK
  * @category Achievements
  * @package Player
###
class Levelable extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.level.getValue()

    currentCheckValue = 5
    levelInterval = 5
    achieved = []

    while baseStat >= currentCheckValue
      level = currentCheckValue / levelInterval
      achieved.push
        name: "Levelable #{toRoman level}"
        desc: "Become level #{currentCheckValue}"
        reward: "+1 LUCK"
        luck: -> 1
        type: "progress"

      currentCheckValue += levelInterval

    achieved


module.exports = exports = Levelable