
GuildBuff = require "../base/GuildBuff"

`/**
  * The Wisdom guild buff increases Wisdom.
  *
  * @name Wisdom
  * @requirement {gold} (tier+1)^2 + 1000
  * @requirement {guild-level} 10 + 10 per tier
  * @requirement {guild-members} (tier-1)*2 + 1
  * @effect +5% WIS per tier
  * @duration 12 hours + 12 hours per tier
  * @category Wisdom
  * @package GuildBuffs
*/`
class GuildWisdom extends GuildBuff

  constructor: (@tier = 1) ->
    @type = 'Wisdom'
    super()

  wisPercent: -> @tier*5

module.exports = exports = GuildWisdom