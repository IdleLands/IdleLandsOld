
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

class Defensive extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['calculated damage received']

    currentCheckValue = 1000
    multiplier = 10
    level = 1
    achieved = []

    while baseStat >= currentCheckValue
      achieved.push
        name: "Defensive #{toRoman level}"
        desc: "Receive #{currentCheckValue} total damage"
        reward: "+#{level*10} CON"
        con: -> level*10
        type: "combat"

      currentCheckValue *= multiplier
      level++

    achieved


module.exports = exports = Defensive