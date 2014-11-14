
TimePeriod = require "../../TimePeriod"

class DexDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Dexterity"
  @desc = "+5% DEX"

  @dexPercent: -> 5

module.exports = exports = DexDay