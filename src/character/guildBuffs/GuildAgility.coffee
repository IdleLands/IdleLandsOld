
GuildBuff = require "../base/GuildBuff"

`/**
  * The Agility I guild buff increases Agility.
  *
  * @name Agility I
  * @requirement {gold} 4000
  * @requirement {guild-level} 20
  * @requirement {guild-members} 1
  * @effect +5% AGI
  * @duration 1 day
  * @category Agility
  * @package GuildBuffs
*/`
`/**
  * The Agility II guild buff increases Agility.
  *
  * @name Agility II
  * @requirement {gold} 9000
  * @requirement {guild-level} 30
  * @requirement {guild-members} 1
  * @effect +10% AGI
  * @duration 1 day, 12 hours
  * @category Agility
  * @package GuildBuffs
*/`
`/**
  * The Agility III guild buff increases Agility.
  *
  * @name Agility III
  * @requirement {gold} 16000
  * @requirement {guild-level} 40
  * @requirement {guild-members} 4
  * @effect +15% AGI
  * @duration 2 days
  * @category Agility
  * @package GuildBuffs
*/`
`/**
  * The Agility IV guild buff increases Agility.
  *
  * @name Agility IV
  * @requirement {gold} 25000
  * @requirement {guild-level} 50
  * @requirement {guild-members} 4
  * @effect +20% AGI
  * @duration 2 days, 12 hours
  * @category Agility
  * @package GuildBuffs
*/`
`/**
  * The Agility V guild buff increases Agility.
  *
  * @name Agility V
  * @requirement {gold} 36000
  * @requirement {guild-level} 60
  * @requirement {guild-members} 9
  * @effect +25% AGI
  * @duration 3 days
  * @category Agility
  * @package GuildBuffs
*/`
`/**
  * The Agility VI guild buff increases Agility.
  *
  * @name Agility VI
  * @requirement {gold} 49000
  * @requirement {guild-level} 70
  * @requirement {guild-members} 9
  * @effect +30% AGI
  * @duration 3 days, 12 hours
  * @category Agility
  * @package GuildBuffs
*/`
`/**
  * The Agility VII guild buff increases Agility.
  *
  * @name Agility VII
  * @requirement {gold} 64000
  * @requirement {guild-level} 80
  * @requirement {guild-members} 15
  * @effect +35% AGI
  * @duration 4 days
  * @category Agility
  * @package GuildBuffs
*/`
`/**
  * The Agility VIII guild buff increases Agility.
  *
  * @name Agility VIII
  * @requirement {gold} 81000
  * @requirement {guild-level} 90
  * @requirement {guild-members} 15
  * @effect +40% AGI
  * @duration 4 days, 12 hours
  * @category Agility
  * @package GuildBuffs
*/`
`/**
  * The Agility IX guild buff increases Agility.
  *
  * @name Agility IX
  * @requirement {gold} 100000
  * @requirement {guild-level} 100
  * @requirement {guild-members} 20
  * @effect +45% AGI
  * @duration 5 days
  * @category Agility
  * @package GuildBuffs
*/`
class GuildAgility extends GuildBuff

  @tiers = GuildAgility::tiers = [null,
    {name: "Agility I", level: 20, members: 1, cost: 4000, duration: {days: 1}},
    {name: "Agility II", level: 30, members: 1, cost: 9000, duration: {days: 1, hours: 12}},
    {name: "Agility III", level: 40, members: 4, cost: 16000, duration: {days: 2}},
    {name: "Agility IV", level: 50, members: 4, cost: 25000, duration: {days: 2, hours: 12}},
    {name: "Agility V", level: 60, members: 9, cost: 36000, duration: {days: 3}},
    {name: "Agility VI", level: 70, members: 9, cost: 49000, duration: {days: 3, hours: 12}},
    {name: "Agility VII", level: 80, members: 15, cost: 64000, duration: {days: 4}},
    {name: "Agility VIII", level: 90, members: 15, cost: 81000, duration: {days: 4, hours: 12}},
    {name: "Agility IX", level: 100, members: 20, cost: 100000, duration: {days: 5}}
  ]

  constructor: (@tier = 1) ->
    @type = 'Agility'
    super()

  agiPercent: -> @tier*5

module.exports = exports = GuildAgility