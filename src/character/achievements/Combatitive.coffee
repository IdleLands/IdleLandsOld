
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

class Combatitive extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['combat battle start']

    currentCheckValue = 5
    multiplier = 5
    achieved = []

    while baseStat >= currentCheckValue
      level = @log multiplier, currentCheckValue
      achieved.push
        name: "Combatitive #{toRoman level}"
        desc: "Enter #{currentCheckValue} battles"
        reward: "+1 offense/defense"
        offense: -> 1
        defense: -> 1

      currentCheckValue *= multiplier

    achieved


module.exports = exports = Combatitive