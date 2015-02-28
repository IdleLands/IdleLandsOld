
GuildBuff = require "../base/GuildBuff"

`/**
  * The Dexterity guild buff increases Dexterity.
  *
  * @name Dexterity
  * @requirement {gold} (tier+1)^2 + 1000
  * @requirement {guild-level} 10 + 10 per tier
  * @requirement {guild-members} (tier-1)*2 + 1
  * @effect +5% DEX per tier
  * @duration 12 hours + 12 hours per tier
  * @category Basic
  * @package Guild Buffs
*/`

class GuildDexterity extends GuildBuff

  constructor: (@tier = 1) ->
    @type = 'Dexterity'
    super()

  dexPercent: -> @tier*5

module.exports = exports = GuildDexterity