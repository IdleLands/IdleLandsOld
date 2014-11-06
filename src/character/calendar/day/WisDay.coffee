
TimePeriod = require "../../base/TimePeriod"

class WisDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Wisdom"
  @desc = "5% wis boost"

  @wisPercent: -> 5

module.exports = exports = WisDay