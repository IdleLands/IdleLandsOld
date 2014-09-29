
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

class Damaging extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['calculated total damage given']

    currentCheckValue = 1000
    multiplier = 10
    achieved = []

    while baseStat >= currentCheckValue
      level = @log multiplier, currentCheckValue
      achieved.push
        name: "Damaging #{toRoman level}"
        desc: "Deal #{currentCheckValue} total damage"
        reward: "+#{level*10} STR"
        str: -> level*10

      currentCheckValue *= multiplier

    achieved


module.exports = exports = Damaging