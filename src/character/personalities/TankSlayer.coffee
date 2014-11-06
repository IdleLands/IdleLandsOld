
Personality = require "../base/Personality"
Constants = require "../../system/Constants"
_ = require "underscore"

slay = (player, enemies) ->
  targets = _.filter enemies, (enemy) -> enemy.professionName in Constants.classCategorization.tank
  { probability: 300, result: targets }

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