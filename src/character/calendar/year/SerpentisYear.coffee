
TimePeriod = require "../../base/TimePeriod"

class SerpentisYear extends TimePeriod

  constructor: ->
  
  @name = "Year of Serpentis"
  @desc = "Water and Physical boost"

  @water: -> 200
  @waterPercent: -> 14
  @physical: -> 200
  @physicalPercent: -> 14

module.exports = exports = SerpentisYear