
GuildBuff = require "../base/GuildBuff"

`/**
  * The Luck guild buff increases Luck.
  *
  * @name Luck
  * @requirement {gold} (tier+1)^2 + 1000
  * @requirement {guild-level} 10 + 10 per tier
  * @requirement {guild-members} (tier-1)*2 + 1
  * @effect +1% LUCK per tier
  * @duration 12 hours + 12 hours per tier
  * @category Luck
  * @package Guild Buffs
*/`

class GuildLuck extends GuildBuff

  constructor: (@tier = 1) ->
    @type = 'Luck'
    super()

  luckPercent: -> @tier

module.exports = exports = GuildLuck