
TimePeriod = require "../../base/TimePeriod"

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