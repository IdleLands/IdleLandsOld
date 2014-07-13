
Spell = require "../base/Spell"

class Cure extends Spell
  name: "cure"
  @element = Cure::element = Spell::Element.heal
  @cost = Cure::cost = 1
  @restrictions =
    "Cleric": 1

module.exports = exports = Cure