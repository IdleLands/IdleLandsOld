
TimePeriod = require "../../base/TimePeriod"

class GaiaMonth extends TimePeriod

  constructor: ->
  
  @name = "Month of Gaia"
  @desc = "Earth boost"

  @earth: -> 50
  @earthPercent: -> 5

module.exports = exports = GaiaMonth