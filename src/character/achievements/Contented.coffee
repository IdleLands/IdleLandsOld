
Achievement = require "../base/Achievement"
Personality = require "../base/Personality"
{toRoman} = require "roman-numerals"
_ = require "lodash"

`/**
  * This achievement is earned by submitting content. All the cool kids are doing it!
  *
  * @name Contented
  * @prerequisite Submit 5*[n-1]+1 pieces of content.
  * @reward +10% gold
  * @category Achievements
  * @package Player
*/`
class Contented extends Achievement

  getAllAchievedFor: (player) ->

    achieved = []

    baseStat = player.permanentAchievements?.contentSubmissions or 0

    currentCheckValue = 1
    submitInterval = 5
    level = 1
    achieved = []

    while baseStat >= currentCheckValue
      item =
        name: "Contented #{toRoman level}"
        desc: "Submit #{currentCheckValue} pieces of content"
        reward: "+10% gold"
        goldPercent: -> 10
        type: "special"

      achieved.push item

      currentCheckValue *= submitInterval
      level++

    achieved


module.exports = exports = Contented