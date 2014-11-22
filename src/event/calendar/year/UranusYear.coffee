
TimePeriod = require "../../TimePeriod"

`/**
  * The Uranus year increases ice and holy.
  *
  * @name Uranus Year
  * @effect +200 holy
  * @effect +14% holy
  * @effect +200 ice
  * @effect +14% ice
  * @category Year
  * @package Calendar
*/`
class UranusYear extends TimePeriod

  constructor: ->

  @dateName = "Year of Uranus"
  @desc = "Ice and holy boost"
  
  @ice: -> 200
  @icePercent: -> 14
  @holy: -> 200
  @holyPercent: -> 14

module.exports = exports = UranusYear