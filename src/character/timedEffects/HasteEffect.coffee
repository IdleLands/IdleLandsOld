
TimedEffect = require "../base/TimedEffect"

class HasteEffect extends TimedEffect
  @name = HasteEffect::name = "HasteEffect"

  `/**
    * Increases movement speed.
    *
    * @name Haste
    * @effect +1 Haste
    * @package TimedEffects
  */`

  haste: -> 1

  constructor: ->
    super

module.exports = exports = HasteEffect
