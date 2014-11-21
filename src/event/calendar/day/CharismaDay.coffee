
TimePeriod = require "../../TimePeriod"

###*
  * The Charisma day lowers shop prices.
  *
  * @name Charisma Day
  * @effect -15% Shop Prices
  * @category Day
  * @package Calendar
###
class CharismaDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Charisma"
  @desc = "15% shop price reduction"

  @shopPercent: -> -15

module.exports = exports = CharismaDay