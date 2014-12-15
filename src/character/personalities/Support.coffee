
Personality = require "../base/Personality"
Constants = require "../../system/Constants"

`/**
  * This personality makes you never change classes, unless the resulting class is considered Support.
  *
  * @name Support
  * @prerequisite Use 100 duration skills.
  * @effect Slightly more likely to get party gold blessings
  * @effect Slightly more likely to get party XP blessings
  * @effect Slightly more likely to get into parties
  * @effect +3% AGI
  * @effect +3% DEX
  * @effect -8% WIS
  * @category Personalities
  * @package Player
*/`
class Support extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type in ["blessXpParty", "blessGoldParty", "party"] then 100

  agiPercent: -> 3
  dexPercent: -> 3
  wisPercent: -> -8

  classChangePercent: (potential) ->
    -100 if not Constants.isSupport potential

  @canUse = (player) ->
    player.statistics["combat self skill duration begin"] >= 100

  @desc = "Use 100 duration spells"

module.exports = exports = Support