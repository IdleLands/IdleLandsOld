
TimedEffect = require "../base/TimedEffect"

class DiseaseEffect extends TimedEffect
  @name = DiseaseEffect::name = "DiseaseEffect"

  `/**
    * Decreases CON and hp regen.
    *
    * @name Disease
    * @effect -5% of max hp lost per turn
    * @effect -10% CON
    * @package TimedEffects
  */`

  hpregen: (player) -> Math.floor(player.hp.maximum*-0.05)
  conPercent: -> -10

  constructor: ->
    super

module.exports = exports = DiseaseEffect
