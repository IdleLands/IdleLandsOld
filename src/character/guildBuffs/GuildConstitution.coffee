
GuildBuff = require "../base/GuildBuff"

`/**
  * The Constitution guild buff increases Constitution.
  *
  * @name Constitution
  * @requirement {gold} (tier+1)^2 + 1000
  * @requirement {guild-level} 10 + 10 per tier
  * @requirement {guild-members} (tier-1)*2 + 1
  * @effect +5% CON per tier
  * @duration 12 hours + 12 hours per tier
  * @category Basic
  * @package Guild Buffs
*/`

class GuildConstitution extends GuildBuff

  constructor: (@tier = 1) ->
    @type = 'Constitution'
    super()

  conPercent: -> @tier*5

module.exports = exports = GuildConstitution