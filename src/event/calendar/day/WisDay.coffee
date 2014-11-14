
TimePeriod = require "../../TimePeriod"

class WisDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Wisdom"
  @desc = "+5% WIS"

  @wisPercent: -> 5

module.exports = exports = WisDay