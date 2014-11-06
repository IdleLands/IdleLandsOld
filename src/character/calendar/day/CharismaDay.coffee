
TimePeriod = require "../../base/TimePeriod"

class CharismaDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Charisma"
  @desc = "15% shop price reduction"

  @shopPercent: -> -15

module.exports = exports = CharismaDay