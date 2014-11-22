
Personality = require "../base/Personality"

`/**
  * This personality makes you never change classes, unless the resulting class is considered Magical.
  *
  * @name Magical
  * @prerequisite Find 50 items
  * @effect itemScore + int + wis - str*1.5 - dex*1.5
  * @effect +5% INT
  * @effect +5% WIS
  * @effect -10% STR
  * @effect -10% DEX
  * @category Personalities
  * @package Player
*/`
class Magical extends Personality
  constructor: ->

  intPercent: -> 5
  wisPercent: -> 5

  strPercent: -> -10
  dexPercent: -> -10

  itemScore: (player, item) ->
    item.int
    + item.wis
    - item.str*1.5
    - item.dex*1.5

  classChangePercent: (potential) ->
    -100 if not Personality.isMagical potential
    
  @canUse = (player) ->
    player.statistics["event findItem"] >= 50

  @desc = "Equip 50 items"

module.exports = exports = Magical