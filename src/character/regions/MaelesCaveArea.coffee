
Region = require "../base/Region"

class MaelesCaveArea extends Region

  constructor: ->
  
  @desc = "Strength boost"

  @strPercent: -> 10

module.exports = exports = MaelesCaveArea