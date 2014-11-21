
TimePeriod = require "../../TimePeriod"

###*
  * The Evil day increases all stats for all evil aligned entities - monsters and players alike. It lowers those stats for good players.
  *
  * @name Evil Day
  * @effect +alignment% DEX
  * @effect +alignment% STR
  * @effect +alignment% INT
  * @effect +alignment% WIS
  * @effect +alignment% AGI
  * @effect +alignment% CON
  * @effect +alignment% LUCK
  * @category Day
  * @package Calendar
###
class EvilDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Evil"
  @desc = "Stat boost for evil-aligned characters"

  @dexPercent: (character) -> -character.calc.alignment()
  @strPercent: (character) -> -character.calc.alignment()
  @intPercent: (character) -> -character.calc.alignment()
  @wisPercent: (character) -> -character.calc.alignment()
  @agiPercent: (character) -> -character.calc.alignment()
  @conPercent: (character) -> -character.calc.alignment()
  @luckPercent: (character) -> -character.calc.alignment()

module.exports = exports = EvilDay