
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "underscore"

`/**
  * This achievement is obtained when creating a character. It only lasts for 3 days, so idle wisely.
  *
  * @name Beginners Luck
  * @prerequisite None
  * @reward +50 LUCK
  * @category Achievements
  * @package Player
*/`
class BeginnersLuck extends Achievement

  getAllAchievedFor: (player) ->

    achieved = []

    hoursPlayed = (Math.abs player.registrationDate.getTime()-Date.now()) / 36e5

    if hoursPlayed <= 72 # you get this for 3 days

      item =
        name: "Beginner's Luck"
        desc: "Welcome to Idle Lands!"
        reward: "+50 LUCK"
        luck: -> 50
        type: "combat"

      achieved.push item

    achieved


module.exports = exports = BeginnersLuck