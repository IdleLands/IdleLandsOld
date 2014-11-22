
TimePeriod = require "../../TimePeriod"

`/**
  * The LUCK day increases luck.
  *
  * @name LUCK Day
  * @effect +5% LUCK
  * @category Day
  * @package Calendar
*/`
class LuckDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Luck"
  @desc = "+5% LUCK"

  @luckPercent: -> 5

module.exports = exports = LuckDay