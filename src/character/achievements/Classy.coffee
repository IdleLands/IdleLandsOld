
Achievement = require "../base/Achievement"

requireDir = require "require-dir"
_ = require "underscore"

classProtos = requireDir "../classes"
classList = _.pluck classProtos, 'name'

baseStats = ['Str', 'Dex', 'Con', 'Agi', 'Int', 'Wis', 'Luck']

class Classy extends Achievement

  getAllAchievedFor: (player) ->
    achieved = []

    beenTo = _.filter classList, (className) -> className of player.statistics['calculated class changes']

    _.each beenTo, (className) ->

      base =
        name: "Classy: #{className}"
        desc: "Become a #{className}"
        reward: ""

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