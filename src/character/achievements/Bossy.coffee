
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "underscore"

class Bossy extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = (_.keys player.statistics['calculated boss kills']).length

    currentCheckValue = 3
    killInterval = 5
    achieved = []

    while baseStat >= currentCheckValue
      level = currentCheckValue / killInterval
      item =
        name: "Bossy #{toRoman level}"
        desc: "Kill #{currentCheckValue} unique bosses"
        reward: "+2% AGI, +2% DEX"
        agiPercent: -> 2
        dexPercent: -> 2
        type: "combat"

      achieved.push item

      currentCheckValue *= killInterval

    achieved


module.exports = exports = Bossy