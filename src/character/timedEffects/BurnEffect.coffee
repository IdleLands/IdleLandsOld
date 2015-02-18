
TimedEffect = require "../base/TimedEffect"

class BurnEffect extends TimedEffect
  @name = BurnEffect::name = "BurnEffect"

  `/**
    * Decreases maximum health.
    *
    * @name Burn
    * @effect -20% hp
    * @package TimedEffects
  */`

  hpPercent: -> -20

  constructor: ->
    super

module.exports = exports = BurnEffect
