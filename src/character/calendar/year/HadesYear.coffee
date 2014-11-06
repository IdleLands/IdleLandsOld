
TimePeriod = require "../../base/TimePeriod"

class HadesYear extends TimePeriod

  constructor: ->

  @name = "Year of Hades"
  @desc = "Fire and Dark boost"  

  @fire: -> 200
  @firePercent: -> 14
  @dark: -> 200
  @darkPercent: -> 14

module.exports = exports = HadesYear