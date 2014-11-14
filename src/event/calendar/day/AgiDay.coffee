
TimePeriod = require "../../TimePeriod"

class AgiDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Agility"
  @desc = "+5% AGI"

  @agiPercent: -> 5

module.exports = exports = AgiDay