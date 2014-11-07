
TimePeriod = require "../../base/TimePeriod"

class AetherYear extends TimePeriod

  constructor: ->
  
  @dateName = "Year of Aether"
  @desc = "Energy and Thunder boost"

  @energy: -> 200
  @energyPercent: -> 14
  @thunder: -> 200
  @thunderPercent: -> 14

module.exports = exports = AetherYear