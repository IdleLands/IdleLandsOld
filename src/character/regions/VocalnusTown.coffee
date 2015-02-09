
Region = require "../base/Region"

`/**
 * This region grants you a small shop.
 *
 * @name Vocalnus Town
 * @effect Small shops
 * @category Norkos
 * @package World Regions
 */`
class VocalnusTown extends Region

  constructor: ->

  @name = "Vocalnus Town"
  @desc = "A small shop"

  @shopPercent: -> 1
  @shopMult: -> 0.9
  @shopSlots: -> 3
  @shopQuality: -> 1.4

  @eventModifier: (player, event) -> if event.type is "towncrier" then 500

module.exports = exports = VocalnusTown