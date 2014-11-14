
TimePeriod = require "../../TimePeriod"

class BoreasMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Boreas"
  @desc = "Ice boost"

  @ice: -> 50
  @icePercent: -> 5

module.exports = exports = BoreasMonth