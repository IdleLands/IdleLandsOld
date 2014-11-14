
TimePeriod = require "../../TimePeriod"

class LuckDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Luck"
  @desc = "+5% LUCK"

  @luckPercent: -> 5

module.exports = exports = LuckDay