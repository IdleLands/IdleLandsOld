
TimePeriod = require "../../TimePeriod"

###*
  * The Monster day increases all stats for monsters.
  *
  * @name Monster Day
  * @effect +10% DEX (Only applies to monsters)
  * @effect +10% STR (Only applies to monsters)
  * @effect +10% INT (Only applies to monsters)
  * @effect +10% WIS (Only applies to monsters)
  * @effect +10% AGI (Only applies to monsters)
  * @effect +10% CON (Only applies to monsters)
  * @effect +10% LUCK (Only applies to monsters)
  * @category Day
  * @package Calendar
###
class MonsterDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Monsters"
  @desc = "+10% all monster stats"

  @dexPercent: (character) -> 10 if not character.playerManager
  @strPercent: (character) -> 10 if not character.playerManager
  @intPercent: (character) -> 10 if not character.playerManager
  @wisPercent: (character) -> 10 if not character.playerManager
  @agiPercent: (character) -> 10 if not character.playerManager
  @conPercent: (character) -> 10 if not character.playerManager
  @luckPercent: (character) -> 10 if not character.playerManager

module.exports = exports = MonsterDay