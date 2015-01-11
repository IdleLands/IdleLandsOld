
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "lodash"

`/**
  * This achievement is earned by exploring unique maps.
  *
  * @name Explorative
  * @prerequisite Explore 5*[5*[n-1]+1] maps.
  * @reward +2% CON
  * @reward +2% INT
  * @reward +1 haste (This only applies once for every 5 levels of Explorative.)
  * @category Achievements
  * @package Player
*/`
class Explorative extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = (_.keys player.statistics['calculated map changes']).length

    currentCheckValue = 5
    levelInterval = 5
    achieved = []

    while baseStat >= currentCheckValue
      level = currentCheckValue / levelInterval
      item =
        name: "Explorative #{toRoman level}"
        desc: "Explore #{currentCheckValue} maps"
        reward: "+2% INT, +2% CON#{if level%%5 is 0 then ", +1 haste" else ""}"
        conPercent: -> 2
        intPercent: -> 2
        type: "exploration"

      item.title = "Explorer" if level is 5

      if level%%5 is 0
        item.haste = -> 1

      achieved.push item

      currentCheckValue += levelInterval

    achieved


module.exports = exports = Explorative