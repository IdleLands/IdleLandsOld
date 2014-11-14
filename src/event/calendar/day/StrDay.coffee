
TimePeriod = require "../../TimePeriod"

class StrDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Strength"
  @desc = "+5% STR"

  @strPercent: -> 5

module.exports = exports = StrDay