
Region = require "../base/Region"

`/**
 * This region gives you more strength. Hoo-ah!
 *
 * @name Maeles Cave Area
 * @effect +10% STR
 * @category Norkos
 * @package World Regions
 */`
class MaelesCaveArea extends Region

  constructor: ->

  @name = "Maeles Cave Area"
  @desc = "Strength boost"

  @strPercent: -> 10

module.exports = exports = MaelesCaveArea