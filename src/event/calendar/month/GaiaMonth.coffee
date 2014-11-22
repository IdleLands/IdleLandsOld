
TimePeriod = require "../../TimePeriod"

`/**
  * The Gaia month increases earth.
  *
  * @name Gaia Month
  * @effect +50 earth
  * @effect +5% earth
  * @category Month
  * @package Calendar
*/`
class GaiaMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Gaia"
  @desc = "Earth boost"

  @earth: -> 50
  @earthPercent: -> 5

module.exports = exports = GaiaMonth