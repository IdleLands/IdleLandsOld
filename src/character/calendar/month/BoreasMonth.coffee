
TimePeriod = require "../../base/TimePeriod"

class BoreasMonth extends TimePeriod

  constructor: ->
  
  @name = "Month of Boreas"
  @desc = "Ice boost"

  @ice: -> 50
  @icePercent: -> 5

module.exports = exports = BoreasMonth