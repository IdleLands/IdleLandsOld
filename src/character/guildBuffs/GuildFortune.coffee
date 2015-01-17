
GuildBuff = require "../base/GuildBuff"

`/**
  * The Fortune I guild buff increases gold found and item quality.
  *
  * @name Fortune I
  * @requirement {gold} 4000
  * @requirement {guild-level} 20
  * @requirement {guild-members} 1
  * @effect +5% gold
  * @effect +5% item find range
  * @duration 12 hours
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune II guild buff increases gold found and item quality.
  *
  * @name Fortune II
  * @requirement {gold} 9000
  * @requirement {guild-level} 30
  * @requirement {guild-members} 1
  * @effect +10% gold
  * @effect +10% item find range
  * @duration 18 hours
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune III guild buff increases gold found and item quality.
  *
  * @name Fortune III
  * @requirement {gold} 16000
  * @requirement {guild-level} 40
  * @requirement {guild-members} 4
  * @effect +15% gold
  * @effect +15% item find range
  * @duration 1 day
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune IV guild buff increases gold found and item quality.
  *
  * @name Fortune IV
  * @requirement {gold} 25000
  * @requirement {guild-level} 50
  * @requirement {guild-members} 4
  * @effect +20% gold
  * @effect +20% item find range
  * @duration 1 day, 6 hours
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune V guild buff increases gold found and item quality.
  *
  * @name Fortune V
  * @requirement {gold} 36000
  * @requirement {guild-level} 60
  * @requirement {guild-members} 9
  * @effect +25% gold
  * @effect +25% item find range
  * @duration 1 day, 12 hours
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune VI guild buff increases gold found and item quality.
  *
  * @name Fortune VI
  * @requirement {gold} 49000
  * @requirement {guild-level} 70
  * @requirement {guild-members} 9
  * @effect +30% gold
  * @effect +30% item find range
  * @duration 1 day, 18 hours
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune VII guild buff increases gold found and item quality.
  *
  * @name Fortune VII
  * @requirement {gold} 64000
  * @requirement {guild-level} 80
  * @requirement {guild-members} 15
  * @effect +35% gold
  * @effect +35% item find range
  * @duration 2 days
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune VIII guild buff increases gold found and item quality.
  *
  * @name Fortune VIII
  * @requirement {gold} 81000
  * @requirement {guild-level} 90
  * @requirement {guild-members} 15
  * @effect +40% gold
  * @effect +40% item find range
  * @duration 2 days, 6 hours
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune IX guild buff increases gold found and item quality.
  *
  * @name Fortune IX
  * @requirement {gold} 100000
  * @requirement {guild-level} 100
  * @requirement {guild-members} 20
  * @effect +45% gold
  * @effect +45% item find range
  * @duration 2 days, 12 hours
  * @category Fortune
  * @package GuildBuffs
*/`
class GuildFortune extends GuildBuff

  @tiers = GuildFortune::tiers = [null,
    {name: "Fortune I", level: 20, members: 1, cost: 4000, duration: {hours: 12}},
    {name: "Fortune II", level: 30, members: 1, cost: 9000, duration: {hours: 18}},
    {name: "Fortune III", level: 40, members: 4, cost: 16000, duration: {days: 1}},
    {name: "Fortune IV", level: 50, members: 4, cost: 25000, duration: {days: 1, hours: 6}},
    {name: "Fortune V", level: 60, members: 9, cost: 36000, duration: {days: 1, hours: 12}},
    {name: "Fortune VI", level: 70, members: 9, cost: 49000, duration: {days: 1, hours: 18}},
    {name: "Fortune VII", level: 80, members: 15, cost: 64000, duration: {days: 2}},
    {name: "Fortune VIII", level: 90, members: 15, cost: 81000, duration: {days: 2, hours: 6}},
    {name: "Fortune IX", level: 100, members: 20, cost: 100000, duration: {days: 2, hours: 12}}
  ]

  constructor: (@tier = 1) ->
    @type = 'Fortune'
    super()

  goldPercent: -> @tier*5
  itemFindRangeMultiplier: -> @tier*0.05

module.exports = exports = GuildFortune