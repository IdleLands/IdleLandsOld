
TimePeriod = require "../../TimePeriod"

###*
  * The Hermes month increases thunder.
  *
  * @name Hermes Month
  * @effect +50 thunder
  * @effect +5% thunder
  * @category Month
  * @package Calendar
###
class HermesMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Hermes"
  @desc = "Thunder boost"

  @thunder: -> 50
  @thunderPercent: -> 5

module.exports = exports = HermesMonth