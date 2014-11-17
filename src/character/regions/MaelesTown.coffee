
Region = require "../base/Region"

class MaelesTown extends Region

  constructor: ->

  @name = "Maeles Town"
  @desc = "Strength boost and artisan shops"

  @strPercent: -> 10
  @shopMult: -> 2
  @shopSlots: -> 2
  @shopQuality: -> 1.5

module.exports = exports = MaelesTown