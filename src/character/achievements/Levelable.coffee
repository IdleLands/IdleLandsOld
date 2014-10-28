
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

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
        reward: "+1 luck"
        luck: -> 1
        type: "event"

      currentCheckValue += levelInterval

    achieved


module.exports = exports = Levelable