
TimePeriod = require "../../base/TimePeriod"

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