
Region = require "../base/Region"

class DangerousCaveArea extends Region

  constructor: ->
  
  @desc = "Battles are more frequent"

  @eventModifier: (player, event) -> if event.type is "battle" then 300

module.exports = exports = DangerousCaveArea