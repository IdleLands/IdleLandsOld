
TimePeriod = require "../../base/TimePeriod"

class ConDay extends TimePeriod

  constructor: ->
  
  @name = "Day of Vitality"
  @desc = "5% con boost"

  @conPercent: -> 5

module.exports = exports = ConDay