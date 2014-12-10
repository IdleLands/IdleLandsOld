
Personality = require "../base/Personality"
Constants = require "../../system/Constants"
_ = require "lodash"

slay = (player, enemies) ->
  targets = _.filter enemies.result, (enemy) -> Constants.isDPS enemy.professionName
  { probability: 300, result: targets }

`/**
  * This personality makes you more likely to target DPS-type classes.
  *
  * @name DPSSlayer
  * @prerequisite Kill 10 DPS classes
  * @category Personalities
  * @package Player
*/`
class DPSSlayer extends Personality
  constructor: ->

  physicalAttackTargets: slay
  magicalAttackTargets: slay

  @canUse = (player) ->

    root = player.statistics["calculated kills by class"]
    return no if not root

    count = 0
    _.each Constants.classCategorization.support, (dpsClass) ->
      count += root[dpsClass]

    count > 10

  @desc = "Kill 10 DPS-types"

module.exports = exports = DPSSlayer