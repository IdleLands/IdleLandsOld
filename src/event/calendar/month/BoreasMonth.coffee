
TimePeriod = require "../../TimePeriod"

###*
  * The Boreas month increases ice.
  *
  * @name Boreas Month
  * @effect +50 ice
  * @effect +5% ice
  * @category Month
  * @package Calendar
###
class BoreasMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Boreas"
  @desc = "Ice boost"

  @ice: -> 50
  @icePercent: -> 5

module.exports = exports = BoreasMonth