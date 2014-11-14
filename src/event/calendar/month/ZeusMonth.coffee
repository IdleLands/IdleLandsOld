
TimePeriod = require "../../TimePeriod"

class ZeusMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Zeus"
  @desc = "Physical boost"

  @physical: -> 50
  @physicalPercent: -> 5

module.exports = exports = ZeusMonth