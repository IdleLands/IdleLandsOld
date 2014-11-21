
TimePeriod = require "../../TimePeriod"

###*
  * The AGI day raises agility.
  *
  * @name AGI Day
  * @effect +5% AGI
  * @category Day
  * @package Calendar
###
class AgiDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Agility"
  @desc = "+5% AGI"

  @agiPercent: -> 5

module.exports = exports = AgiDay