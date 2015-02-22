
GuildBuff = require "../base/GuildBuff"

`/**
  * The Agility guild buff increases Agility.
  *
  * @name Agility
  * @requirement {gold} (tier+1)^2 + 1000
  * @requirement {guild-level} 10 + 10 per tier
  * @requirement {guild-members} (tier-1)*2 + 1
  * @effect +5% AGI per tier
  * @duration 12 hours + 12 hours per tier
  * @category Agility
  * @package GuildBuffs
*/`

class GuildAgility extends GuildBuff

  constructor: (@tier = 1) ->
    @type = 'Agility'
    super()

  agiPercent: -> @tier*5

module.exports = exports = GuildAgility