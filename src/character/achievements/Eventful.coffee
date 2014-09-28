
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

class Eventful extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['event']

    currentCheckValue = 10
    multiplier = 10
    achieved = []

    while baseStat > currentCheckValue
      level = @log multiplier, currentCheckValue
      achieved.push
        name: "Eventful #{toRoman level}"
        desc: "Experience #{currentCheckValue} events"
        reward: "+#{(level*0.1).toFixed 1} itemFindRangeMultiplier"
        itemFindRangeMultiplier: -> level*0.1

      currentCheckValue *= multiplier

    achieved


module.exports = exports = Eventful