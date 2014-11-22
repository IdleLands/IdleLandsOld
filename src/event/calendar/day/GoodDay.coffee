
TimePeriod = require "../../TimePeriod"

`/**
  * The Good day increases all stats for all good aligned entities - monsters and players alike. It lowers those stats for evil players.
  *
  * @name Good Day
  * @effect +alignment% DEX
  * @effect +alignment% STR
  * @effect +alignment% INT
  * @effect +alignment% WIS
  * @effect +alignment% AGI
  * @effect +alignment% CON
  * @effect +alignment% LUCK
  * @category Day
  * @package Calendar
*/`
class GoodDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Good"
  @desc = "Stat boost for good-aligned characters"

  @dexPercent: (character) -> character.calc.alignment()
  @strPercent: (character) -> character.calc.alignment()
  @intPercent: (character) -> character.calc.alignment()
  @wisPercent: (character) -> character.calc.alignment()
  @agiPercent: (character) -> character.calc.alignment()
  @conPercent: (character) -> character.calc.alignment()
  @luckPercent: (character) -> character.calc.alignment()

module.exports = exports = GoodDay