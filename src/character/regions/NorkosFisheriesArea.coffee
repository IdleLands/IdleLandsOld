
Region = require "../base/Region"

class NorkosFisheriesArea extends Region

  constructor: ->

  @name = "Norkos Fisheries Area"
  @desc = "Dex boost"

  @dexPercent: -> 10

module.exports = exports = NorkosFisheriesArea