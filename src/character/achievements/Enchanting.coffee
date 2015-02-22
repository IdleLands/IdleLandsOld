
Achievement = require "../base/Achievement"
Personality = require "../base/Personality"
_ = require "lodash"

`/**
  * This achievement is earned by getting and maintaining a +100
  *
  * @name Enchanting
  * @prerequisite Get to +100 enchantment level
  * @reward +100 to event probability
  * @category Achievements
  * @package Player
*/`
class Enchanting extends Achievement

  getAllAchievedFor: (player) ->

    achieved = []

    if player.permanentAchievements?.plus100
      achieved.push
        name: "Enchanting"
        desc: "Got to +100 enchantment level"
        reward: "+100 to event probability"
        eventModifier: -> 100
        type: "special"
        title: "Stingy Enchanter"

    achieved


module.exports = exports = Enchanting