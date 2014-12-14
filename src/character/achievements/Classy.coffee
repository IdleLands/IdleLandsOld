
Achievement = require "../base/Achievement"

requireDir = require "require-dir"
_ = require "lodash"

classProtos = requireDir "../classes"
classList = _.pluck classProtos, 'name'

baseStats = ['Str', 'Dex', 'Con', 'Agi', 'Int', 'Wis', 'Luck']

`/**
  * This achievement is earned by becoming a new class.
  *
  * @name Classy
  * @prerequisite Become a new class.
  * @reward Varies, depending on the class.
  * @category Achievements
  * @package Player
*/`
class Classy extends Achievement

  getAllAchievedFor: (player) ->
    achieved = []

    return [] if not ('calculated class changes' of player.statistics)
    beenTo = _.filter classList, (className) -> className of player.statistics?['calculated class changes']

    _.each beenTo, (className) ->

      base =
        name: "Classy: #{className}"
        desc: "Become a #{className}"
        reward: ""
        type: "class"

      currentProto = classProtos[className].prototype

      applicableStats = _.reject baseStats, (stat) -> currentProto["base#{stat}PerLevel"] is 0

      _.each applicableStats, (stat) ->
        base[stat.toLowerCase()] = -> currentProto["base#{stat}PerLevel"]

      base.reward = (_.map applicableStats, (stat) ->
        value = currentProto["base#{stat}PerLevel"]
        "#{if value > 0 then '+' else ''}#{value} #{stat.toUpperCase()}"
      ).join ", "

      achieved.push base

    achieved


module.exports = exports = Classy