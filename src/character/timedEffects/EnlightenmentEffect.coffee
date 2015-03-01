
TimedEffect = require "../base/TimedEffect"

class EnlightenmentEffect extends TimedEffect
  @name = EnlightenmentEffect::name = "EnlightenmentEffect"

  `/**
    * Increases intelligence and wisdom.
    *
    * @name Enlightenment
    * @effect +20% INT
    * @effect +20% WIS
    * @category OOC Buffs
    * @package Player
  */`

  intPercent: -> 20
  wisPercent: -> 20

  constructor: ->
    super

module.exports = exports = EnlightenmentEffect
