
Personality = require "../base/Personality"
Constants = require "../../system/Constants"
_ = require "lodash"

slay = (player, enemies) ->
  targets = _.filter enemies.result, (enemy) -> Constants.isSupport enemy.professionName
  { probability: 300, result: targets }

`/**
  * This personality makes you more likely to target Support-type classes.
  *
  * @name SupportSlayer
  * @prerequisite Kill 10 Support classes
  * @category Personalities
  * @package Player
*/`
class SupportSlayer extends Personality
  constructor: ->

  physicalAttackTargets: slay
  magicalAttackTargetS: slay

  @canUse = (player) ->

    root = player.statistics["calculated kills by class"]
    return no if not root

    count = 0
    _.each Constants.classCategorization.support, (supportClass) ->
      count += root[supportClass]

    count > 10

  @desc = "Kill 10 Support-types"

module.exports = exports = SupportSlayer