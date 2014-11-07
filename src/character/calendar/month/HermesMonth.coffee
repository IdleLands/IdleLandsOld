
TimePeriod = require "../../base/TimePeriod"

class HermesMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Hermes"
  @desc = "Thunder boost"

  @thunder: -> 50
  @thunderPercent: -> 5

module.exports = exports = HermesMonth