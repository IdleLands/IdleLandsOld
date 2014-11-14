
TimePeriod = require "../../TimePeriod"

class UranusYear extends TimePeriod

  constructor: ->

  @dateName = "Year of Uranus"
  @desc = "Ice and holy boost"
  
  @ice: -> 200
  @icePercent: -> 14
  @holy: -> 200
  @holyPercent: -> 14

module.exports = exports = UranusYear