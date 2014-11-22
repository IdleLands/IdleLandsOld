
TimePeriod = require "../../TimePeriod"

`/**
  * The Crono month increases healing.
  *
  * @name Crono Month
  * @effect +50 heal
  * @effect +5% heal
  * @category Month
  * @package Calendar
*/`
class CronoMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Crono"
  @desc = "Healing boost"

  @heal: -> 50
  @healPercent: -> 5

module.exports = exports = CronoMonth