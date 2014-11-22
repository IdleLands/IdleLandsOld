
Personality = require "../base/Personality"

`/**
  * This personality makes you never change classes, unless the resulting class is considered Physical.
  *
  * @name Physical
  * @prerequisite Find 50 items
  * @effect itemScore + str + dex - int*1.5 - wis*1.5
  * @effect +5% STR
  * @effect +5% DEX
  * @effect -10% INT
  * @effect -10% WIS
  * @category Personalities
  * @package Player
*/`
class Physical extends Personality
  constructor: ->

  intPercent: -> -10
  wisPercent: -> -10

  strPercent: -> 5
  dexPercent: -> 5

  itemScore: (player, item) ->
    item.str
    + item.dex
    - item.int*1.5
    - item.wis*1.5

  classChangePercent: (potential) ->
    -100 if not Personality.isPhysical potential

  @canUse = (player) ->
    player.statistics["event findItem"] >= 50

  @desc = "Equip 50 items"

module.exports = exports = Physical