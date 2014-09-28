
Achievement = require "../base/Achievement"
Personality = require "../base/Personality"
_ = require "underscore"

class Personable extends Achievement

  getAllAchievedFor: (player) ->

    achieved = []

    achievedPersonalities = _.filter Personality::allPersonalities(), (personality) -> personality.canUse player

    _.each achievedPersonalities, (personality) ->
      achieved.push
        name: "Personality: #{personality.name}"
        desc: personality.desc
        reward: "Can now use personality \"#{personality.name}\""

    achieved


module.exports = exports = Personable