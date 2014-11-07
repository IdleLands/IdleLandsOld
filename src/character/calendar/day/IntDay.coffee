
TimePeriod = require "../../base/TimePeriod"

class IntDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Intelligence"
  @desc = "5% int boost"

  @intPercent: -> 5

module.exports = exports = IntDay