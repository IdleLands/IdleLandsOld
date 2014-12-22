
GuildBuff = require "../base/GuildBuff"

`/**
  * The Fortune I guild buff increases gold found and item quality.
  *
  * @name Fortune I
  * @requirement {gold} 4000
  * @requirement {guild level} 20
  * @effect +5% gold
  * @effect +5% item find range
  * @duration 1 day
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune II guild buff increases gold found and item quality.
  *
  * @name Fortune II
  * @requirement {gold} 9000
  * @requirement {guild level} 30
  * @effect +10% gold
  * @effect +10% item find range
  * @duration 1 day, 12 hours
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune III guild buff increases gold found and item quality.
  *
  * @name Fortune III
  * @requirement {gold} 16000
  * @requirement {guild level} 40
  * @effect +15% gold
  * @effect +15% item find range
  * @duration 2 days
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune IV guild buff increases gold found and item quality.
  *
  * @name Fortune IV
  * @requirement {gold} 25000
  * @requirement {guild level} 50
  * @effect +20% gold
  * @effect +20% item find range
  * @duration 2 days, 12 hours
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune V guild buff increases gold found and item quality.
  *
  * @name Fortune V
  * @requirement {gold} 36000
  * @requirement {guild level} 60
  * @effect +25% gold
  * @effect +25% item find range
  * @duration 3 days
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune VI guild buff increases gold found and item quality.
  *
  * @name Fortune VI
  * @requirement {gold} 49000
  * @requirement {guild level} 80
  * @effect +30% gold
  * @effect +30% item find range
  * @duration 3 days, 12 hours
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune VII guild buff increases gold found and item quality.
  *
  * @name Fortune VII
  * @requirement {gold} 64000
  * @requirement {guild level} 80
  * @effect +35% gold
  * @effect +35% item find range
  * @duration 4 days
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune VIII guild buff increases gold found and item quality.
  *
  * @name Fortune VIII
  * @requirement {gold} 81000
  * @requirement {guild level} 90
  * @effect +40% gold
  * @effect +40% item find range
  * @duration 4 days, 12 hours
  * @category Fortune
  * @package GuildBuffs
*/`
`/**
  * The Fortune IX guild buff increases gold found and item quality.
  *
  * @name Fortune IX
  * @requirement {gold} 100000
  * @requirement {guild level} 100
  * @effect +45% gold
  * @effect +45% item find range
  * @duration 5 days
  * @category Fortune
  * @package GuildBuffs
*/`
class GuildFortune extends GuildBuff

  @tiers = GuildFortune::tiers = [null,
    {name: "Fortune I", level: 20, cost: 4000, duration: {days: 1}},
    {name: "Fortune II", level: 30, cost: 9000, duration: {days: 1, hours: 12}},
    {name: "Fortune III", level: 40, cost: 16000, duration: {days: 2}},
    {name: "Fortune IV", level: 50, cost: 25000, duration: {days: 2, hours: 12}},
    {name: "Fortune V", level: 60, cost: 36000, duration: {days: 3}},
    {name: "Fortune VI", level: 70, cost: 49000, duration: {days: 3, hours: 12}},
    {name: "Fortune VII", level: 80, cost: 64000, duration: {days: 4}},
    {name: "Fortune VIII", level: 90, cost: 81000, duration: {days: 4, hours: 12}},
    {name: "Fortune IX", level: 100, cost: 100000, duration: {days: 5}}
  ]

  constructor: (@tier = 1) ->
    @type = 'Fortune'
    super()

  goldPercent: -> @tier*5
  itemFindRangeMultiplier: -> @tier*0.05

module.exports = exports = GuildFortune