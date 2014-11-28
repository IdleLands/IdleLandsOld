
Region = require "../base/Region"

`/**
 * This region makes battles more frequent. Beware!
 *
 * @name Dangerous Cave Area
 * @effect Battles are more frequent.
 * @category Norkos
 * @package World Regions
 */`
class DangerousCaveArea extends Region

  constructor: ->

  @name = "Dangerous Cave Area"
  @desc = "Battles are more frequent"

  @eventModifier: (player, event) -> if event.type is "battle" then 300

module.exports = exports = DangerousCaveArea