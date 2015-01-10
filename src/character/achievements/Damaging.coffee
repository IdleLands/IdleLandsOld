
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

`/**
  * This achievement is earned by doing a lot of damage.
  *
  * @name Damaging
  * @prerequisite Give 1000*[10*[n-1]+1] damage.
  * @reward +[achievementLevel*10] STR
  * @category Achievements
  * @package Player
*/`
class Damaging extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['calculated total damage given']

    currentCheckValue = 1000
    multiplier = 10
    level = 1
    achieved = []

    while baseStat >= currentCheckValue
      item =
        name: "Damaging #{toRoman level}"
        desc: "Deal #{currentCheckValue} total damage"
        reward: "+#{level*10} STR"
        str: -> level*10
        type: "combat"

      item.title = "Unstoppable" if level is 5

      achieved.push item

      currentCheckValue *= multiplier
      level++

    achieved


module.exports = exports = Damaging