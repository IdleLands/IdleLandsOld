
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "lodash"

`/**
  * This achievement, in a perfect world, will never be earned. But, feel free to try!
  *
  * @name Impossible
  * @prerequisite Varies
  * @reward Bragging rights
  * @category Achievements
  * @package Player
*/`
class Impossible extends Achievement

  getAllAchievedFor: (player) ->
    achieved = []

    howDidYouEvenGetThisCollectible = _.findWhere player.collectibles, {name: "How Did You Even Get Out Here"}

    if howDidYouEvenGetThisCollectible
      achieved.push
        name: "Impossible I"
        desc: "Find a certain collectible in Norkos -9"
        reward: "Bragging rights"
        title: "Leet H4x0r"
        type: "special"

    achieved


module.exports = exports = Impossible