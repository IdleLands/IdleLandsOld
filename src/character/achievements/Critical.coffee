
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

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