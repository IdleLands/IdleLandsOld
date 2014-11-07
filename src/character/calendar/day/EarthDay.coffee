
TimePeriod = require "../../base/TimePeriod"

class EarthDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of the Earth"
  @desc = "Boost to all elemental magic"

  @fire: -> 25
  @firePercent: -> 3
  @ice: -> 25
  @icePercent: -> 3
  @earth: -> 25
  @earthPercent: -> 3
  @water: -> 25
  @waterPercent: -> 3
  @thunder: -> 25
  @thunderPercent: -> 3

module.exports = exports = EarthDay