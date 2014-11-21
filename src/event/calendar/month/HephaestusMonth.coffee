
TimePeriod = require "../../TimePeriod"

###*
  * The Hephaestus month increases fire.
  *
  * @name Hephaestus Month
  * @effect +50 fire
  * @effect +5% fire
  * @category Month
  * @package Calendar
###
class HephaestusMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Hephaestus"
  @desc = "Fire boost"

  @fire: -> 50
  @firePercent: -> 5

module.exports = exports = HephaestusMonth