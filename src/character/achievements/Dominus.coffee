
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "underscore"

class Dominus extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['event bossbattle win']

    currentCheckValue = 10
    killInterval = 10
    achieved = []

    while baseStat >= currentCheckValue
      level = currentCheckValue / killInterval
      item =
        name: "Dominus #{toRoman level}"
        desc: "Kill #{currentCheckValue} bosses"
        reward: "+5 AGI, +5 DEX"
        agi: -> 5
        dex: -> 5
        type: "combat"

      achieved.push item

      currentCheckValue += killInterval

    achieved


module.exports = exports = Dominus