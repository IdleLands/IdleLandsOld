
TimePeriod = require "../../base/TimePeriod"

class StrDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Strength"
  @desc = "5% str boost"

  @strPercent: -> 5

module.exports = exports = StrDay