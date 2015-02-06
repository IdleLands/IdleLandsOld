
Region = require "../base/Region"

`/**
 * This region grants you a surprisingly good shop. Niche goods for niche explorers.
 *
 * @name Homlet Town
 * @effect Exquisite shops
 * @category Norkos
 * @package World Regions
 */`
class HomletTown extends Region

  constructor: ->

  @name = "Homlet Town"
  @desc = "An exquisite shop"

  @shopPercent: -> 1.3
  @shopMult: -> 1.7
  @shopSlots: -> 1
  @shopQuality: -> 2.3

  @eventModifier: (player, event) -> if event.type is "advertisement" then 500

module.exports = exports = HomletTown