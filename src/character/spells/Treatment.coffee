
Spell = require "../base/Spell"

class Treatment extends Spell
  name: "treatment"
  @element = Treatment::element = Spell::Element.heal
  @cost = Treatment::cost = 1000
  @restrictions =
    "Generalist": 3

    #HoT

module.exports = exports = Treatment