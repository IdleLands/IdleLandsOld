
TimedEffect = require "../base/TimedEffect"

class BlessEffect extends TimedEffect
  @name = BlessEffect::name = "BlessEffect"

  `/**
    * Increases all stats.
    *
    * @name Bless
    * @effect +5% AGI
    * @effect +5% DEX
    * @effect +5% STR
    * @effect +5% CON
    * @effect +5% INT
    * @effect +5% WIS
    * @effect +5% LUCK
    * @category OOC Buffs
    * @package Player
  */`

  agiPercent: -> 5
  dexPercent: -> 5
  strPercent: -> 5
  conPercent: -> 5
  intPercent: -> 5
  wisPercent: -> 5
  luckPercent: -> 5

  constructor: ->
    super

module.exports = exports = BlessEffect
