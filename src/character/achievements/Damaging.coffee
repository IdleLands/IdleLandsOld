
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

class Damaging extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['calculated total damage given']

    currentCheckValue = 1000
    multiplier = 10
    level = 1
    achieved = []

    while baseStat >= currentCheckValue
      achieved.push
        name: "Damaging #{toRoman level}"
        desc: "Deal #{currentCheckValue} total damage"
        reward: "+#{level*10} STR"
        str: -> level*10
        type: "combat"

      currentCheckValue *= multiplier
      level++

    achieved


module.exports = exports = Damaging