
TimePeriod = require "../../TimePeriod"

`/**
  * The STR day increases strength.
  *
  * @name STR Day
  * @effect +5% STR
  * @category Day
  * @package Calendar
*/`
class StrDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Strength"
  @desc = "+5% STR"

  @strPercent: -> 5

module.exports = exports = StrDay