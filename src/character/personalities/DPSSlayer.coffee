
Personality = require "../base/Personality"
Constants = require "../../system/Constants"
_ = require "underscore"

class DPSSlayer extends Personality
  constructor: ->

  physicalAttackTargets: (player, enemies) ->
    targets = _.filter enemies, (enemy) -> enemy.professionName in Constants.classCategorization.dps
    { probability: 100, result: targets }

  @canUse = (player) ->

    root = player.statistics["calculated kills by class"]
    return no if not root

    count = 0
    _.each Constants.classCategorization.support, (dpsClass) ->
      count += root[dpsClass]

    count > 10

  @desc = "Kill 10 DPS-types"

module.exports = exports = DPSSlayer