
TimePeriod = require "../../TimePeriod"

class DemeterYear extends TimePeriod

  constructor: ->

  @dateName = "Year of Demeter"
  @desc = "Heal and Earth boost"
  
  @heal: -> 200
  @healPercent: -> 14
  @earth: -> 200
  @earthPercent: -> 14

module.exports = exports = DemeterYear