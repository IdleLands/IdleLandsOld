
TimedEffect = require "../base/TimedEffect"

class WeaknessEffect extends TimedEffect
  @name = WeaknessEffect::name = "WeaknessEffect"

  `/**
    * Reduces strength and constitution.
    *
    * @name Weakness
    * @effect -20% STR
    * @effect -20% CON
    * @category OOC Buffs
    * @package Player
  */`

  strPercent: -> -20
  conPercent: -> -20

  constructor: ->
    super

module.exports = exports = WeaknessEffect
