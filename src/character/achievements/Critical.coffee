
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

`/**
  * This achievement is earned by performing a lot of critical hits.
  *
  * @name Critical
  * @prerequisite Perform 500*[10*[n-1]+1] critical hits.
  * @reward +1 crit
  * @category Achievements
  * @package Player
*/`
class Critical extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['combat self critical']

    currentCheckValue = 500
    multiplier = 10
    level = 1
    achieved = []

    while baseStat >= currentCheckValue
      achieved.push
        name: "Critical #{toRoman level}"
        desc: "Perform #{currentCheckValue} critical hits"
        reward: "+1 crit"
        crit: -> 1
        type: "combat"

      currentCheckValue *= multiplier
      level++

    achieved


module.exports = exports = Critical