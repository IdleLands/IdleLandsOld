
TimePeriod = require "../../base/TimePeriod"

class GaiaMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Gaia"
  @desc = "Earth boost"

  @earth: -> 50
  @earthPercent: -> 5

module.exports = exports = GaiaMonth