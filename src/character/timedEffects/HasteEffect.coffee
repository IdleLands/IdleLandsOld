
TimedEffect = require "../base/TimedEffect"

class HasteEffect extends TimedEffect
  @name = HasteEffect::name = "HasteEffect"

  `/**
    * Increases movement speed.
    *
    * @name Haste
    * @effect +1 Haste
    * @category OOC Buffs
    * @package Player
  */`

  haste: -> 1

  constructor: ->
    super

module.exports = exports = HasteEffect
