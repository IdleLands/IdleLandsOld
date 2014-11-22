
TimePeriod = require "../../TimePeriod"

`/**
  * The WIS day increases wisdom.
  *
  * @name WIS Day
  * @effect +5% WIS
  * @category Day
  * @package Calendar
*/`
class WisDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Wisdom"
  @desc = "+5% WIS"

  @wisPercent: -> 5

module.exports = exports = WisDay