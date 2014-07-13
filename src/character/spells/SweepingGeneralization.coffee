
Spell = require "../base/Spell"

class SweepingGeneralization extends Spell
  name: "sweeping generalization"
  @element = SweepingGeneralization::element = Spell::Element.normal
  @cost = SweepingGeneralization::cost = 1
  @restrictions =
    "Generalist": 1

module.exports = exports = SweepingGeneralization