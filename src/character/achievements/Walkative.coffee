
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
      item =
        name: "Walkative #{toRoman level}"
        desc: "Take #{currentCheckValue} steps"
        reward: "+1 xp#{if level%%5 is 0 then ", +1 haste" else ""}"
        xp: -> 1
        type: "exploration"

      if level%%5 is 0
        item.haste = -> 1

      achieved.push item

      currentCheckValue *= multiplier

    achieved


module.exports = exports = Walkative
