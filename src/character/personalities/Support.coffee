
Personality = require "../base/Personality"
Constants = require "../../system/Constants"

`/**
  * This personality makes you never change classes, unless the resulting class is considered Support.
  *
  * @name Support
  * @prerequisite Use 100 duration skills.
  * @category Personalities
  * @package Player
*/`
class Support extends Personality
  constructor: ->

  classChangePercent: (potential) ->
    -100 if not Constants.isSupport potential

  @canUse = (player) ->
    player.statistics["combat self skill duration begin"] >= 100

  @desc = "Use 100 duration spells"

module.exports = exports = Support