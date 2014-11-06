
TimePeriod = require "../../base/TimePeriod"

class LuckDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Luck"
  @desc = "5% luck boost"

  @luckPercent: -> 5

module.exports = exports = LuckDay