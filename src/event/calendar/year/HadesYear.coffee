
TimePeriod = require "../../TimePeriod"

`/**
  * The Hades year increases fire and dark.
  *
  * @name Hades Year
  * @effect +200 fire
  * @effect +14% fire
  * @effect +200 dark
  * @effect +14% dark
  * @category Year
  * @package Calendar
*/`
class HadesYear extends TimePeriod

  constructor: ->

  @dateName = "Year of Hades"
  @desc = "Fire and Dark boost"

  @fire: -> 200
  @firePercent: -> 14
  @dark: -> 200
  @darkPercent: -> 14

module.exports = exports = HadesYear