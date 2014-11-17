
Region = require "../base/Region"

class NorkosVolcanoArea extends Region

  constructor: ->

  @name = "Norkos Volcano Area"
  @desc = "Fire boost"

  @fire: -> 250

module.exports = exports = NorkosVolcanoArea