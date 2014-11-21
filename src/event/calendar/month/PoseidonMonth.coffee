
TimePeriod = require "../../TimePeriod"

###*
  * The Poseidon month increases water.
  *
  * @name Poseidon Month
  * @effect +50 water
  * @effect +5% water
  * @category Month
  * @package Calendar
###
class PoseidonMonth extends TimePeriod

  constructor: ->
  
  @dateName = "Month of Poseidon"
  @desc = "Water boost"

  @water: -> 50
  @waterPercent: -> 5

module.exports = exports = PoseidonMonth