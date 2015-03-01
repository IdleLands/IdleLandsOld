
GuildBuff = require "../base/GuildBuff"

`/**
  * The Intelligence guild buff increases Intelligence.
  *
  * @name Intelligence
  * @requirement {gold} (tier+1)^2 + 1000
  * @requirement {guild-level} 10 + 10 per tier
  * @requirement {guild-members} (tier-1)*2 + 1
  * @effect +5% INT per tier
  * @duration 12 hours + 12 hours per tier
  * @category Basic
  * @package Guild Buffs
*/`

class GuildIntelligence extends GuildBuff

  constructor: (@tier = 1) ->
    @type = 'Intelligence'
    super()

  intPercent: -> @tier*5

module.exports = exports = GuildIntelligence