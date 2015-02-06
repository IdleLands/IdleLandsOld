
Region = require "../base/Region"

`/**
 * This region grants you a luck boost and makes shops cheaper.
 *
 * @name Norkos Town
 * @effect +5 LUCK
 * @effect Shops are cheaper
 * @category Norkos
 * @package World Regions
 */`
class NorkosTown extends Region

  constructor: ->

  @name = "Norkos Town"
  @desc = "Luck boost and cheaper shopping"

  @luck: -> 5
  @shopPercent: -> -10
  @shopMult: -> 1
  @shopSlots: -> 4
  @shopQuality: -> 1
  @eventModifier: (player, event) -> if event.type is "advertisement" then 500

module.exports = exports = NorkosTown