
GuildBuff = require "../base/GuildBuff"

`/**
  * The Strength guild buff increases Strength.
  *
  * @name Strength
  * @requirement {gold} (tier+1)^2 + 1000
  * @requirement {guild-level} 10 + 10 per tier
  * @requirement {guild-members} (tier-1)*2 + 1
  * @effect +5% STR per tier
  * @duration 12 hours + 12 hours per tier
  * @category Buffs
  * @package Guild
*/`

class GuildStrength extends GuildBuff

  constructor: (@tier = 1) ->
    @type = 'Strength'
    super()

  strPercent: -> @tier*5

module.exports = exports = GuildStrength