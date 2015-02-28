
TimedEffect = require "../base/TimedEffect"

class SlowEffect extends TimedEffect
  @name = SlowEffect::name = "SlowEffect"

  `/**
    * Reduces movement speed.
    *
    * @name Slow
    * @effect -20% Haste
    * @category OOC Buffs
    * @package Player
  */`

  haste: -> -1

  constructor: ->
    super

module.exports = exports = SlowEffect
