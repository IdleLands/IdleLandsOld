
Region = require "../base/Region"

class MaelesCaveArea extends Region

  constructor: ->

  @name = "Maeles Cave Area"
  @desc = "Strength boost"

  @strPercent: -> 10

module.exports = exports = MaelesCaveArea