
Personality = require "../base/Personality"
Constants = require "../../system/Constants"
_ = require "lodash"

slay = (player, enemies) ->
  targets = _.filter enemies.result, (enemy) -> Constants.isTank enemy.professionName
  { probability: 300, result: targets }

`/**
  * This personality makes you more likely to target Tank-type classes.
  *
  * @name TankSlayer
  * @prerequisite Kill 10 Tank classes
  * @category Personalities
  * @package Player
*/`
class TankSlayer extends Personality
  constructor: ->

  physicalAttackTargets: slay
  magicalAttackTargets: slay

  @canUse = (player) ->

    root = player.statistics["calculated kills by class"]
    return no if not root

    count = 0
    _.each Constants.classCategorization.tank, (tankClass) ->
      count += root[tankClass]

    count > 10

  @desc = "Kill 10 Tank-types"

module.exports = exports = TankSlayer