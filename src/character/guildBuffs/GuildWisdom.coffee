
GuildBuff = require "../base/GuildBuff"

`/**
  * The Wisdom I guild buff increases Wisdom.
  *
  * @name Wisdom I
  * @requirement {gold} 4000
  * @requirement {guild-level} 20
  * @requirement {guild-members} 1
  * @effect +5% WIS
  * @duration 1 day
  * @category Wisdom
  * @package GuildBuffs
*/`
`/**
  * The Wisdom II guild buff increases Wisdom.
  *
  * @name Wisdom II
  * @requirement {gold} 9000
  * @requirement {guild-level} 30
  * @requirement {guild-members} 1
  * @effect +10% WIS
  * @duration 1 day, 12 hours
  * @category Wisdom
  * @package GuildBuffs
*/`
`/**
  * The Wisdom III guild buff increases Wisdom.
  *
  * @name Wisdom III
  * @requirement {gold} 16000
  * @requirement {guild-level} 40
  * @requirement {guild-members} 4
  * @effect +15% WIS
  * @duration 2 days
  * @category Wisdom
  * @package GuildBuffs
*/`
`/**
  * The Wisdom IV guild buff increases Wisdom.
  *
  * @name Wisdom IV
  * @requirement {gold} 25000
  * @requirement {guild-level} 50
  * @requirement {guild-members} 4
  * @effect +20% WIS
  * @duration 2 days, 12 hours
  * @category Wisdom
  * @package GuildBuffs
*/`
`/**
  * The Wisdom V guild buff increases Wisdom.
  *
  * @name Wisdom V
  * @requirement {gold} 36000
  * @requirement {guild-level} 60
  * @requirement {guild-members} 9
  * @effect +25% WIS
  * @duration 3 days
  * @category Wisdom
  * @package GuildBuffs
*/`
`/**
  * The Wisdom VI guild buff increases Wisdom.
  *
  * @name Wisdom VI
  * @requirement {gold} 49000
  * @requirement {guild-level} 70
  * @requirement {guild-members} 9
  * @effect +30% WIS
  * @duration 3 days, 12 hours
  * @category Wisdom
  * @package GuildBuffs
*/`
`/**
  * The Wisdom VII guild buff increases Wisdom.
  *
  * @name Wisdom VII
  * @requirement {gold} 64000
  * @requirement {guild-level} 80
  * @requirement {guild-members} 15
  * @effect +35% WIS
  * @duration 4 days
  * @category Wisdom
  * @package GuildBuffs
*/`
`/**
  * The Wisdom VIII guild buff increases Wisdom.
  *
  * @name Wisdom VIII
  * @requirement {gold} 81000
  * @requirement {guild-level} 90
  * @requirement {guild-members} 15
  * @effect +40% WIS
  * @duration 4 days, 12 hours
  * @category Wisdom
  * @package GuildBuffs
*/`
`/**
  * The Wisdom IX guild buff increases Wisdom.
  *
  * @name Wisdom IX
  * @requirement {gold} 100000
  * @requirement {guild-level} 100
  * @requirement {guild-members} 20
  * @effect +45% WIS
  * @duration 5 days
  * @category Wisdom
  * @package GuildBuffs
*/`
class GuildWisdom extends GuildBuff

  @tiers = GuildWisdom::tiers = [null,
    {name: "Wisdom I", level: 20, members: 1, cost: 4000, duration: {days: 1}},
    {name: "Wisdom II", level: 30, members: 1, cost: 9000, duration: {days: 1, hours: 12}},
    {name: "Wisdom III", level: 40, members: 4, cost: 16000, duration: {days: 2}},
    {name: "Wisdom IV", level: 50, members: 4, cost: 25000, duration: {days: 2, hours: 12}},
    {name: "Wisdom V", level: 60, members: 9, cost: 36000, duration: {days: 3}},
    {name: "Wisdom VI", level: 70, members: 9, cost: 49000, duration: {days: 3, hours: 12}},
    {name: "Wisdom VII", level: 80, members: 15, cost: 64000, duration: {days: 4}},
    {name: "Wisdom VIII", level: 90, members: 15, cost: 81000, duration: {days: 4, hours: 12}},
    {name: "Wisdom IX", level: 100, members: 20, cost: 100000, duration: {days: 5}}
  ]

  constructor: (@tier = 1) ->
    @type = 'Wisdom'
    super()

  wisPercent: -> @tier*5

module.exports = exports = GuildWisdom