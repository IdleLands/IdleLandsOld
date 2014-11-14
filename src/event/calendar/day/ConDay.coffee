
TimePeriod = require "../../TimePeriod"

class ConDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Vitality"
  @desc = "+5% CON"

  @conPercent: -> 5

module.exports = exports = ConDay