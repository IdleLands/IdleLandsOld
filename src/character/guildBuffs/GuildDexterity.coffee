
GuildBuff = require "../base/GuildBuff"

`/**
  * The Dexterity I guild buff increases Dexterity.
  *
  * @name Dexterity I
  * @requirement {gold} 4000
  * @requirement {guild-level} 20
  * @requirement {guild-members} 1
  * @effect +5% DEX
  * @duration 1 day
  * @category Dexterity
  * @package GuildBuffs
*/`
`/**
  * The Dexterity II guild buff increases Dexterity.
  *
  * @name Dexterity II
  * @requirement {gold} 9000
  * @requirement {guild-level} 30
  * @requirement {guild-members} 1
  * @effect +10% DEX
  * @duration 1 day, 12 hours
  * @category Dexterity
  * @package GuildBuffs
*/`
`/**
  * The Dexterity III guild buff increases Dexterity.
  *
  * @name Dexterity III
  * @requirement {gold} 16000
  * @requirement {guild-level} 40
  * @requirement {guild-members} 4
  * @effect +15% DEX
  * @duration 2 days
  * @category Dexterity
  * @package GuildBuffs
*/`
`/**
  * The Dexterity IV guild buff increases Dexterity.
  *
  * @name Dexterity IV
  * @requirement {gold} 25000
  * @requirement {guild-level} 50
  * @requirement {guild-members} 4
  * @effect +20% DEX
  * @duration 2 days, 12 hours
  * @category Dexterity
  * @package GuildBuffs
*/`
`/**
  * The Dexterity V guild buff increases Dexterity.
  *
  * @name Dexterity V
  * @requirement {gold} 36000
  * @requirement {guild-level} 60
  * @requirement {guild-members} 9
  * @effect +25% DEX
  * @duration 3 days
  * @category Dexterity
  * @package GuildBuffs
*/`
`/**
  * The Dexterity VI guild buff increases Dexterity.
  *
  * @name Dexterity VI
  * @requirement {gold} 49000
  * @requirement {guild-level} 70
  * @requirement {guild-members} 9
  * @effect +30% DEX
  * @duration 3 days, 12 hours
  * @category Dexterity
  * @package GuildBuffs
*/`
`/**
  * The Dexterity VII guild buff increases Dexterity.
  *
  * @name Dexterity VII
  * @requirement {gold} 64000
  * @requirement {guild-level} 80
  * @requirement {guild-members} 15
  * @effect +35% DEX
  * @duration 4 days
  * @category Dexterity
  * @package GuildBuffs
*/`
`/**
  * The Dexterity VIII guild buff increases Dexterity.
  *
  * @name Dexterity VIII
  * @requirement {gold} 81000
  * @requirement {guild-level} 90
  * @requirement {guild-members} 15
  * @effect +40% DEX
  * @duration 4 days, 12 hours
  * @category Dexterity
  * @package GuildBuffs
*/`
`/**
  * The Dexterity IX guild buff increases Dexterity.
  *
  * @name Dexterity IX
  * @requirement {gold} 100000
  * @requirement {guild-level} 100
  * @requirement {guild-members} 20
  * @effect +45% DEX
  * @duration 5 days
  * @category Dexterity
  * @package GuildBuffs
*/`
class GuildDexterity extends GuildBuff

  @tiers = GuildDexterity::tiers = [null,
    {name: "Dexterity I", level: 20, members: 1, cost: 4000, duration: {days: 1}},
    {name: "Dexterity II", level: 30, members: 1, cost: 9000, duration: {days: 1, hours: 12}},
    {name: "Dexterity III", level: 40, members: 4, cost: 16000, duration: {days: 2}},
    {name: "Dexterity IV", level: 50, members: 4, cost: 25000, duration: {days: 2, hours: 12}},
    {name: "Dexterity V", level: 60, members: 9, cost: 36000, duration: {days: 3}},
    {name: "Dexterity VI", level: 70, members: 9, cost: 49000, duration: {days: 3, hours: 12}},
    {name: "Dexterity VII", level: 80, members: 15, cost: 64000, duration: {days: 4}},
    {name: "Dexterity VIII", level: 90, members: 15, cost: 81000, duration: {days: 4, hours: 12}},
    {name: "Dexterity IX", level: 100, members: 20, cost: 100000, duration: {days: 5}}
  ]

  constructor: (@tier = 1) ->
    @type = 'Dexterity'
    super()

  dexPercent: -> @tier*5

module.exports = exports = GuildDexterity