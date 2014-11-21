
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"

###*
  * This achievement is earned by entering a lot of battles.
  *
  * @name Combatitive
  * @prerequisite Enter 15*[5*[n-1]+1] battles.
  * @reward +1 offense
  * @reward +1 defense
  * @category Achievements
  * @package Player
###
class Combatitive extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['combat battle start']

    currentCheckValue = 15
    multiplier = 5
    level = 1
    achieved = []

    while baseStat >= currentCheckValue
      achieved.push
        name: "Combatitive #{toRoman level}"
        desc: "Enter #{currentCheckValue} battles"
        reward: "+1 offense/defense"
        offense: -> 1
        defense: -> 1
        type: "combat"

      currentCheckValue *= multiplier
      level++

    achieved


module.exports = exports = Combatitive