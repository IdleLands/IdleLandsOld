
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

###*
  * This achievement is earned by experiencing a lot of events.
  *
  * @name Eventful
  * @prerequisite Experience 10*[10*[n-1]+1] events.
  * @reward +[achievementLevel*0.1] itemFindRangeMultiplier
  * @category Achievements
  * @package Player
###
class Eventful extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['event']

    currentCheckValue = 10
    multiplier = 10
    achieved = []

    while baseStat >= currentCheckValue
      level = @log multiplier, currentCheckValue
      achieved.push
        name: "Eventful #{toRoman level}"
        desc: "Experience #{currentCheckValue} events"
        reward: "+#{(level*0.1).toFixed 1} itemFindRangeMultiplier"
        itemFindRangeMultiplier: -> level*0.1
        type: "event"

      currentCheckValue *= multiplier

    achieved


module.exports = exports = Eventful