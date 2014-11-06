
TimePeriod = require "../../base/TimePeriod"

class LuckDay extends TimePeriod

  constructor: ->
  
  @name = "Day of Calamity"
  @desc = "5% luck reduction"

  @luckPercent: -> -5

module.exports = exports = LuckDay