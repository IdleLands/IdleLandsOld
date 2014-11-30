
Personality = require "../base/Personality"
Constants = require "../../system/Constants"
_ = require "underscore"

slay = (player, enemies) ->
  targets = _.sortBy (_.compact enemies.result), (enemy) -> enemy.hp.getValue()
  { probability: 200, result: [targets[0]] }

`/**
  * This personality makes you target the weakest enemy when possible.
  *
  * @name Bully
  * @prerequisite Attack 75 times
  * @effect +5% STR
  * @effect -5% INT
  * @effect -5% WIS
  * @category Personalities
  * @package Player
*/`
class Bully extends Personality
  constructor: ->

  physicalAttackTargets: slay
  magicalAttackTargets: slay

  strPercent: -> 5
  intPercent: -> -5
  wisPercent: -> -5

  @canUse = (player) ->
    player.statistics["combat self attack"] >= 75

  @desc = "Attack 75 times"

module.exports = exports = Bully