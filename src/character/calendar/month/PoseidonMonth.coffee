
TimePeriod = require "../../base/TimePeriod"

class PoseidonMonth extends TimePeriod

  constructor: ->
  
  @name = "Month of Poseidon"
  @desc = "Water boost"

  @water: -> 50
  @waterPercent: -> 5

module.exports = exports = PoseidonMonth