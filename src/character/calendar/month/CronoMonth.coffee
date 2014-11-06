
TimePeriod = require "../../base/TimePeriod"

class CronoMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Crono"
  @desc = "Healing boost"

  @heal: -> 50
  @healPercent: -> 5

module.exports = exports = CronoMonth