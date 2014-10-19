
Personality = require "../base/Personality"
Constants = require "../../system/Constants"
_ = require "underscore"

class MedicSlayer extends Personality
  constructor: ->

  physicalAttackTargets: (player, enemies) ->
    targets = _.filter enemies, (enemy) -> enemy.professionName in Constants.classCategorization.medic
    { probability: 100, result: targets }

  @canUse = (player) ->

    root = player.statistics["calculated kills by class"]
    return no if not root

    count = 0
    _.each Constants.classCategorization.support, (medicClass) ->
      count += root[medicClass]

    count > 10

  @desc = "Kill 10 Medic-types"

module.exports = exports = MedicSlayer