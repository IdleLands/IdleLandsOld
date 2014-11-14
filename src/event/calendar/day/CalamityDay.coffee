
TimePeriod = require "../../TimePeriod"

class CalamityDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Calamity"
  @desc = "-5% LUCK"

  @luckPercent: -> -5

module.exports = exports = CalamityDay