
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "underscore"

`/**
  * This achievement is earned by killing unique players.
  *
  * @name PKer
  * @prerequisite Kill 10*[10*[n-1]+1] unique players.
  * @reward +5 STR
  * @reward +5 AGI
  * @reward +5 CON
  * @reward +5 DEX
  * @reward +5 INT
  * @reward +5 WIS
  * @reward +1 LUCK
  * @category Achievements
  * @package Player
*/`
class PKer extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = (_.keys player.statistics['calculated kills']).length

    currentCheckValue = 10
    killInterval = 10
    achieved = []

    while baseStat >= currentCheckValue
      level = currentCheckValue / killInterval
      item =
        name: "PKer #{toRoman level}"
        desc: "Kill #{currentCheckValue} unique players"
        reward: "+5 STR/DEX/AGI/CON/WIS/INT, +1 LUCK"
        agi: -> 5
        dex: -> 5
        wis: -> 5
        con: -> 5
        int: -> 5
        str: -> 5
        luck: -> 1
        type: "combat"

      achieved.push item

      currentCheckValue += killInterval

    achieved


module.exports = exports = PKer