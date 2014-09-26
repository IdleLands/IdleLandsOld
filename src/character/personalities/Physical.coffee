
Personality = require "../base/Personality"

class Physical extends Personality
  constructor: ->

  intPercent: -> -5
  wisPercent: -> -5

  strPercent: -> 5
  dexPercent: -> 5

  itemScore: (player, item) ->
    item.str*1.5
    + item.dex*1.5
    - item.int*1.5
    - item.wis*1.5

  classChangePercent: (potential) ->
    -100 if @isMagical potential

  @canUse = (player) ->
    player.statistics["event findItem"] >= 50

module.exports = exports = Physical