
TimePeriod = require "../../TimePeriod"

`/**
  * The Calamity day lowers luck.
  *
  * @name Calamity
  * @effect -5% LUCK
  * @category Day
  * @package Calendar
*/`
class CalamityDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Calamity"
  @desc = "-5% LUCK"

  @luckPercent: -> -5

module.exports = exports = CalamityDay
