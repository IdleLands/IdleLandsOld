
Personality = require "../base/Personality"

class Explorer extends Personality

  constructor: (player) ->
    @xpListener = (player)
    player.on 'walk', ->
      player.gainXp 5

  unbind: (player) ->

  intPercent: -> -10
  conPercent: -> -10
  strPercent: -> -10
  dexPercent: -> -10
  wisPercent: -> -10
  agiPercent: -> -10

  @canUse = (player) ->
    player.statistics["walk"] > 100000

module.exports = exports = Explorer