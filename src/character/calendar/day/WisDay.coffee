
TimePeriod = require "../../base/TimePeriod"

class WisDay extends TimePeriod

  constructor: ->
  
  @name = "Day of Wisdom"
  @desc = "5% wis boost"

  @wisPercent: -> 5

module.exports = exports = WisDay