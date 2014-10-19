
Personality = require "../base/Personality"
Constants = require "../../system/Constants"
_ = require "underscore"

class SupportSlayer extends Personality
  constructor: ->

  physicalAttackTargets: (player, enemies) ->
    targets = _.filter enemies, (enemy) -> enemy.professionName in Constants.classCategorization.support
    { probability: 100, result: targets }

  @canUse = (player) ->

    root = player.statistics["calculated kills by class"]
    return no if not root

    count = 0
    _.each Constants.classCategorization.support, (supportClass) ->
      count += root[supportClass]

    count > 10

  @desc = "Kill 10 Support-types"

module.exports = exports = SupportSlayer