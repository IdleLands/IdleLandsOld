
Region = require "../base/Region"

class MaelesTown extends Region

  constructor: ->
  
  @desc = "Strength boost and cheaper shopping"

  @strPercent: -> 10
  @shopPercent: -> -10

module.exports = exports = MaelesTown