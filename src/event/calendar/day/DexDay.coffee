
TimePeriod = require "../../TimePeriod"

`/**
  * The DEX day increases dexterity.
  *
  * @name DEX Day
  * @effect +5% DEX
  * @category Day
  * @package Calendar
*/`
class DexDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Dexterity"
  @desc = "+5% DEX"

  @dexPercent: -> 5

module.exports = exports = DexDay