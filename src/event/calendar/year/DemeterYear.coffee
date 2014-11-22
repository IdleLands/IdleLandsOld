
TimePeriod = require "../../TimePeriod"

`/**
  * The Demeter year increases healing and earth.
  *
  * @name Demeter Year
  * @effect +200 earth
  * @effect +14% earth
  * @effect +200 heal
  * @effect +14% heal
  * @category Year
  * @package Calendar
*/`
class DemeterYear extends TimePeriod

  constructor: ->

  @dateName = "Year of Demeter"
  @desc = "Heal and Earth boost"
  
  @heal: -> 200
  @healPercent: -> 14
  @earth: -> 200
  @earthPercent: -> 14

module.exports = exports = DemeterYear