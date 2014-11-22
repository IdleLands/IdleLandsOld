
TimePeriod = require "../../TimePeriod"

`/**
  * The CON day increases constitution.
  *
  * @name CON Day
  * @effect +5% CON
  * @category Day
  * @package Calendar
*/`
class ConDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Vitality"
  @desc = "+5% CON"

  @conPercent: -> 5

module.exports = exports = ConDay