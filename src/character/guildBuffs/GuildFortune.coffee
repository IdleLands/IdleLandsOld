
GuildBuff = require "../base/GuildBuff"

`/**
  * The Fortune guild buff increases gold found and item quality.
  *
  * @name Fortune
  * @requirement {gold} (tier+1)^2 + 1000
  * @requirement {guild-level} 10 + 10 per tier
  * @requirement {guild-members} (tier-1)*2 + 1
  * @effect +5% gold per tier
  * @effect +5% item find range per tier
  * @duration 6 hours + 6 hours per tier
  * @category Buffs
  * @package Guild
*/`

class GuildFortune extends GuildBuff

  constructor: (@tier = 1) ->
    @type = 'Fortune'
    super(0.5)

  goldPercent: -> @tier*5
  itemFindRangeMultiplier: -> @tier*0.05

module.exports = exports = GuildFortune