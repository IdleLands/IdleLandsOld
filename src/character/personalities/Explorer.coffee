
Personality = require "../base/Personality"

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

  ascendChance: -> 50
  descendChance: -> 50
  teleportChance: -> 50

  @canUse = (player) ->
    player.statistics["explore walk"] >= 100000

module.exports = exports = Explorer