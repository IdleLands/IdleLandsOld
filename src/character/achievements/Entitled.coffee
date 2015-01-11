
Achievement = require "../base/Achievement"

`/**
  * This achievement is attained by getting titles. Lots of them.
  *
  * @name Entitled
  * @prerequisite Get 15 titles.
  * @reward +1 title
  * @category Achievements
  * @package Player
*/`
class Entitled extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player._oldTitles?.length or 0

    achieved = []

    if baseStat >= 15
      item =
        name: "Entitled"
        desc: "Get 15 titles"
        reward: "+1 title"
        type: "progress"
        title: "Entitled"

      achieved.push item

    achieved


module.exports = exports = Entitled
