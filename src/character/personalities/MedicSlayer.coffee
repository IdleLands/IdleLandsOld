
Personality = require "../base/Personality"
Constants = require "../../system/Constants"
_ = require "underscore"

slay = (player, enemies) ->
  targets = _.filter enemies.result, (enemy) -> enemy.professionName in Constants.classCategorization.medic
  { probability: 300, result: targets }

`/**
  * This personality makes you more likely to target Medic-type classes.
  *
  * @name MedicSlayer
  * @prerequisite Kill 10 Medic classes
  * @category Personalities
  * @package Player
*/`
class MedicSlayer extends Personality
  constructor: ->

  physicalAttackTargets: slay
  magicalAttackTargets: slay

  @canUse = (player) ->

    root = player.statistics["calculated kills by class"]
    return no if not root

    count = 0
    _.each Constants.classCategorization.support, (medicClass) ->
      count += root[medicClass]

    count > 10

  @desc = "Kill 10 Medic-types"

module.exports = exports = MedicSlayer