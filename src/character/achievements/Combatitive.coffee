
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

class Combatitive extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['combat battle start']

    currentCheckValue = 15
    multiplier = 5
    level = 1
    achieved = []

    while baseStat >= currentCheckValue
      achieved.push
        name: "Combatitive #{toRoman level}"
        desc: "Enter #{currentCheckValue} battles"
        reward: "+1 offense/defense"
        offense: -> 1
        defense: -> 1
        type: "combat"

      currentCheckValue *= multiplier
      level++

    achieved


module.exports = exports = Combatitive