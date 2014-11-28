
Region = require "../base/Region"

`/**
 * This region grants a boost to fire damage.
 *
 * @name Norkos Volcano Area
 * @effect +250 fire
 * @category Norkos
 * @package World Regions
 */`
class NorkosVolcanoArea extends Region

  constructor: ->

  @name = "Norkos Volcano Area"
  @desc = "Fire boost"

  @fire: -> 250

module.exports = exports = NorkosVolcanoArea