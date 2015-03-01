
TimedEffect = require "../base/TimedEffect"

class FortitudeEffect extends TimedEffect
  @name = FortitudeEffect::name = "FortitudeEffect"

  `/**
    * Increases strength and constitution.
    *
    * @name Fortitude
    * @effect +20% STR
    * @effect +20% CON
    * @category OOC Buffs
    * @package Player
  */`

  strPercent: -> 20
  conPercent: -> 20

  constructor: ->
    super

module.exports = exports = FortitudeEffect
