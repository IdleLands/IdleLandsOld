
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "underscore"

class Classfluid extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = (_.keys player.statistics['calculated class changes']).length

    currentCheckValue = 3
    levelInterval = 3
    achieved = []

    while baseStat >= currentCheckValue
      level = currentCheckValue / levelInterval
      item =
        name: "Classfluid #{toRoman level}"
        desc: "Become #{currentCheckValue} unique classes"
        reward: "+2% STR, +2% WIS"
        strPercent: -> 2
        wisPercent: -> 2
        type: "class"

      achieved.push item

      currentCheckValue += levelInterval

    achieved


module.exports = exports = Classfluid