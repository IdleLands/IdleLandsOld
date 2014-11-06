
TimePeriod = require "../../base/TimePeriod"

class AgiDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Agility"
  @desc = "5% agi boost"

  @agiPercent: -> 5

module.exports = exports = AgiDay