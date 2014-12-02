
Region = require "../base/Region"

`/**
 * This region grants you a shopping mall. Of course, there is a little inflation here, but the variety! It also reeks of ale.
 *
 * @name Raburro Town
 * @effect Lots of shops
 * @effect +3 drunk
 * @category Norkos
 * @package World Regions
 */`
class RaburroTown extends Region

  constructor: ->

  @name = "Raburro Town"
  @desc = "Lots of shop variety"

  @shopPercent: -> 5
  @shopMult: -> 1.3
  @shopSlots: -> 10
  @shopQuality: -> 0.9
  @drunk: -> 3

module.exports = exports = RaburroTown