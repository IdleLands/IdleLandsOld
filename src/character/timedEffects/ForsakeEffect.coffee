
TimedEffect = require "../base/TimedEffect"

class ForsakeEffect extends TimedEffect
  @name = ForsakeEffect::name = "ForsakeEffect"

  `/**
    * Decreases all stats.
    *
    * @name Forsake
    * @effect -5% AGI
    * @effect -5% DEX
    * @effect -5% STR
    * @effect -5% CON
    * @effect -5% INT
    * @effect -5% WIS
    * @effect -5% LUCK
    * @package TimedEffects
  */`

  agiPercent: -> -5
  dexPercent: -> -5
  strPercent: -> -5
  conPercent: -> -5
  intPercent: -> -5
  wisPercent: -> -5
  luckPercent: -> -5

  constructor: ->
    super

module.exports = exports = ForsakeEffect
