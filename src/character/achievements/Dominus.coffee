
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "lodash"

`/**
  * This achievement is earned by killing a lot of bosses.
  *
  * @name Dominus
  * @prerequisite Kill 10*[10*[n-1]+1] bosses.
  * @reward +5 AGI
  * @reward +5 DEX
  * @category Achievements
  * @package Player
*/`
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

      item.title = "Dominator" if level is 5

      achieved.push item

      currentCheckValue += killInterval

    achieved


module.exports = exports = Dominus