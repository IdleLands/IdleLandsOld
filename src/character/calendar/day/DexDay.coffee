
TimePeriod = require "../../base/TimePeriod"

class DexDay extends TimePeriod

  constructor: ->
  
  @name = "Day of Dexterity"
  @desc = "5% dex boost"

  @dexPercent: -> 5

module.exports = exports = DexDay