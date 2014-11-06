
TimePeriod = require "../../base/TimePeriod"

class HephaestusMonth extends TimePeriod

  constructor: ->
  
  @name = "Month of Hephaestus"
  @desc = "Fire boost"

  @fire: -> 50
  @firePercent: -> 5

module.exports = exports = HephaestusMonth