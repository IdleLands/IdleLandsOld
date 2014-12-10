
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "lodash"

`/**
  * This achievement is earned by exploring unique regions.
  *
  * @name Territorial
  * @prerequisite Explore 10*[n] region.
  * @reward +2% STR
  * @reward +2% WIS
  * @category Achievements
  * @package Player
*/`
class Territorial extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = (_.keys player.statistics['calculated regions visited']).length

    currentCheckValue = 10
    levelInterval = 10
    achieved = []

    while baseStat >= currentCheckValue
      level = currentCheckValue / levelInterval
      item =
        name: "Territorial #{toRoman level}"
        desc: "Explore #{currentCheckValue} regions"
        reward: "+2% STR, +2% WIS"
        strPercent: -> 2
        wisPercent: -> 2
        type: "exploration"

      if level%%5 is 0
        item.haste = -> 1

      achieved.push item

      currentCheckValue += levelInterval

    achieved


module.exports = exports = Territorial