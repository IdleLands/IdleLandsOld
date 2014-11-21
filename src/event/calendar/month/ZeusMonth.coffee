
TimePeriod = require "../../TimePeriod"

###*
  * The Zeus month increases physical spells.
  *
  * @name Zeus Month
  * @effect +50 physical
  * @effect +5% physical
  * @category Month
  * @package Calendar
###
class ZeusMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Zeus"
  @desc = "Physical boost"

  @physical: -> 50
  @physicalPercent: -> 5

module.exports = exports = ZeusMonth