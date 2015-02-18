
TimedEffect = require "../base/TimedEffect"

class ChillEffect extends TimedEffect
  @name = ChillEffect::name = "ChillEffect"

  `/**
    * Reduces agility and dexterity.
    *
    * @name Chill
    * @effect -20% AGI
    * @effect -20% DEX
    * @package TimedEffects
  */`

  agiPercent: -> -20
  dexPercent: -> -20

  constructor: ->
    super

module.exports = exports = ChillEffect
