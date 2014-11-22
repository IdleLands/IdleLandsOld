
TimePeriod = require "../../TimePeriod"

`/**
  * The Aether year increases energy and thunder.
  *
  * @name Aether Year
  * @effect +200 energy
  * @effect +14% energy
  * @effect +200 thunder
  * @effect +14% thunder
  * @category Year
  * @package Calendar
*/`
class AetherYear extends TimePeriod

  constructor: ->
  
  @dateName = "Year of Aether"
  @desc = "Energy and Thunder boost"

  @energy: -> 200
  @energyPercent: -> 14
  @thunder: -> 200
  @thunderPercent: -> 14

module.exports = exports = AetherYear