
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

class Walkative extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['explore walk']

    currentCheckValue = 10
    multiplier = 10
    achieved = []

    while baseStat >= currentCheckValue
      level = @log multiplier, currentCheckValue
      achieved.push
        name: "Walkative #{toRoman level}"
        desc: "Take #{currentCheckValue} steps"
        reward: "+1 xp"
        xp: -> 1
        type: "exploration"

      currentCheckValue *= multiplier

    achieved


module.exports = exports = Walkative
