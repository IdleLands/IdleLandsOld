
TimePeriod = require "../../TimePeriod"

###*
  * The INT day increases intelligence.
  *
  * @name INT Day
  * @effect +5% INT
  * @category Day
  * @package Calendar
###
class IntDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Intelligence"
  @desc = "+5% INT"

  @intPercent: -> 5

module.exports = exports = IntDay