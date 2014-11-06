
TimePeriod = require "../../base/TimePeriod"

class ZeusMonth extends TimePeriod

  constructor: ->
  
  @name = "Month of Zeus"
  @desc = "Physical boost"

  @physical: -> 50
  @physicalPercent: -> 5

module.exports = exports = ZeusMonth