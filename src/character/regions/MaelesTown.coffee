
Region = require "../base/Region"

`/**
 * This region gives you strength and makes shops have better results.
 *
 * @name Maeles Town
 * @effect +5% STR
 * @effect Shop quality boost
 * @category Norkos
 * @package World Regions
 */`
class MaelesTown extends Region

  constructor: ->

  @name = "Maeles Town"
  @desc = "Strength boost and artisan shops"

  @strPercent: -> 5
  @shopMult: -> 2
  @shopSlots: -> 2
  @shopQuality: -> 1.5
  @eventModifier: (player, event) -> if event.type is "towncrier" then 500

module.exports = exports = MaelesTown