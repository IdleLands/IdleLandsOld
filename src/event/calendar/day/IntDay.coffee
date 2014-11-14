
TimePeriod = require "../../TimePeriod"

class IntDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Intelligence"
  @desc = "+5% INT"

  @intPercent: -> 5

module.exports = exports = IntDay