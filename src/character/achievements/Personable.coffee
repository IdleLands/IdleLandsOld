
Achievement = require "../base/Achievement"
Personality = require "../base/Personality"
_ = require "lodash"

`/**
  * This achievement is earned by meeting the requirements for a personality.
  *
  * @name Personable
  * @prerequisite Varies per personality
  * @reward Can now use a new personality
  * @category Achievements
  * @package Player
*/`
class Personable extends Achievement

  getAllAchievedFor: (player) ->

    achieved = []

    achievedPersonalities = _.filter Personality::allPersonalities(), (personality) -> personality.canUse player

    _.each achievedPersonalities, (personality) ->
      achieved.push
        name: "Personable: #{personality.name}"
        desc: personality.desc
        reward: "Can now use personality \"#{personality.name}\""
        type: "personality"
        _personality: personality.name

    achieved


module.exports = exports = Personable