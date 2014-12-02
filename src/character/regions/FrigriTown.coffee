
Region = require "../base/Region"

`/**
 * This region has some nice wares.
 *
 * @name Frigri Town
 * @effect Shops have very good items.
 * @category Norkos
 * @package World Regions
 */`
class FrigriTown extends Region

  constructor: ->

  @name = "Frigri Town"
  @desc = "Better shopping experience"

  @luck: -> 5
  @shopPercent: -> 25
  @shopMult: -> 2.5
  @shopSlots: -> 3
  @shopQuality: -> 2.5

module.exports = exports = FrigriTown