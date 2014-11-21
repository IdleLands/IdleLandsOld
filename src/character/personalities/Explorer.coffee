
Personality = require "../base/Personality"

###*
  * This personality affords you better explorer traits to navigate the world, at the cost of stats.
  *
  * @name Explorer
  * @prerequisite Take 100000 steps
  * @effect -10% INT
  * @effect -10% CON
  * @effect -10% STR
  * @effect -10% DEX
  * @effect -10% WIS
  * @effect -10% AGI
  * @effect +1 haste
  * @effect +5 xp (Only applies to explorer actions - move, up stairs, down stairs, etc)
  * @effect +50% chance to go up stairs
  * @effect +50% chance to go down stairs
  * @effect +50% chance to use a teleport
  * @category Personalities
  * @package Player
###
class Explorer extends Personality

  constructor: (player) ->
    @xpListener = (player) ->
      player.gainXp 5

    player.on 'explore.*', @xpListener

  unbind: (player) ->
    player.off 'explore.*', @xpListener

  intPercent: -> -10
  conPercent: -> -10
  strPercent: -> -10
  dexPercent: -> -10
  wisPercent: -> -10
  agiPercent: -> -10

  haste: -> 1

  ascendChance: -> 50
  descendChance: -> 50
  teleportChance: -> 50

  @canUse = (player) ->
    player.statistics["explore walk"] >= 100000
    
  @desc = "Take 100000 steps"

module.exports = exports = Explorer