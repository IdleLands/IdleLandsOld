
Spell = require "../base/Spell"

class DoubleTap extends Spell
  name: "double tap"
  @element = DoubleTap::element = Spell::Element.normal
  @cost = DoubleTap::cost = 1
  @restrictions =
    "Fighter": 1

module.exports = exports = DoubleTap