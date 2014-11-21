
TimePeriod = require "../../TimePeriod"

###*
  * The Serpentis year increases water and physical.
  *
  * @name Serpentis Year
  * @effect +200 water
  * @effect +14% water
  * @effect +200 physical
  * @effect +14% physical
  * @category Year
  * @package Calendar
###
class SerpentisYear extends TimePeriod

  constructor: ->
  
  @dateName = "Year of Serpentis"
  @desc = "Water and Physical boost"

  @water: -> 200
  @waterPercent: -> 14
  @physical: -> 200
  @physicalPercent: -> 14

module.exports = exports = SerpentisYear