
Region = require "../base/Region"

`/**
 * This region grants a boost to dexterity.
 *
 * @name Norkos Fisheries Area
 * @effect +10% DEX
 * @category Norkos
 * @package World Regions
 */`
class NorkosFisheriesArea extends Region

  constructor: ->

  @name = "Norkos Fisheries Area"
  @desc = "Dex boost"

  @dexPercent: -> 10

module.exports = exports = NorkosFisheriesArea