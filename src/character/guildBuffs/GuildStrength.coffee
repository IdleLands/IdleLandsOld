
GuildBuff = require "../base/GuildBuff"

`/**
  * The Strength I guild buff increases Strength.
  *
  * @name Strength I
  * @requirement {gold} 4000
  * @requirement {guild level} 20
  * @effect +5% STR
  * @duration 1 day
  * @category Strength
  * @package GuildBuffs
*/`
`/**
  * The Strength II guild buff increases Strength.
  *
  * @name Strength II
  * @requirement {gold} 9000
  * @requirement {guild level} 30
  * @effect +10% STR
  * @duration 1 day, 12 hours
  * @category Strength
  * @package GuildBuffs
*/`
`/**
  * The Strength III guild buff increases Strength.
  *
  * @name Strength III
  * @requirement {gold} 16000
  * @requirement {guild level} 40
  * @effect +15% STR
  * @duration 2 days
  * @category Strength
  * @package GuildBuffs
*/`
`/**
  * The Strength IV guild buff increases Strength.
  *
  * @name Strength IV
  * @requirement {gold} 25000
  * @requirement {guild level} 50
  * @effect +20% STR
  * @duration 2 days, 12 hours
  * @category Strength
  * @package GuildBuffs
*/`
`/**
  * The Strength V guild buff increases Strength.
  *
  * @name Strength V
  * @requirement {gold} 36000
  * @requirement {guild level} 60
  * @effect +25% STR
  * @duration 3 days
  * @category Strength
  * @package GuildBuffs
*/`
`/**
  * The Strength VI guild buff increases Strength.
  *
  * @name Strength VI
  * @requirement {gold} 49000
  * @requirement {guild level} 80
  * @effect +30% STR
  * @duration 3 days, 12 hours
  * @category Strength
  * @package GuildBuffs
*/`
`/**
  * The Strength VII guild buff increases Strength.
  *
  * @name Strength VII
  * @requirement {gold} 64000
  * @requirement {guild level} 80
  * @effect +35% STR
  * @duration 4 days
  * @category Strength
  * @package GuildBuffs
*/`
`/**
  * The Strength VIII guild buff increases Strength.
  *
  * @name Strength VIII
  * @requirement {gold} 81000
  * @requirement {guild level} 90
  * @effect +40% STR
  * @duration 4 days, 12 hours
  * @category Strength
  * @package GuildBuffs
*/`
`/**
  * The Strength IX guild buff increases Strength.
  *
  * @name Strength IX
  * @requirement {gold} 100000
  * @requirement {guild level} 100
  * @effect +45% STR
  * @duration 5 days
  * @category Strength
  * @package GuildBuffs
*/`
class GuildStrength extends GuildBuff

  @tiers = GuildStrength::tiers = [null,
    {name: "Strength I", level: 20, cost: 4000, duration: {days: 1}},
    {name: "Strength II", level: 30, cost: 9000, duration: {days: 1, hours: 12}},
    {name: "Strength III", level: 40, cost: 16000, duration: {days: 2}},
    {name: "Strength IV", level: 50, cost: 25000, duration: {days: 2, hours: 12}},
    {name: "Strength V", level: 60, cost: 36000, duration: {days: 3}},
    {name: "Strength VI", level: 70, cost: 49000, duration: {days: 3, hours: 12}},
    {name: "Strength VII", level: 80, cost: 64000, duration: {days: 4}},
    {name: "Strength VIII", level: 90, cost: 81000, duration: {days: 4, hours: 12}},
    {name: "Strength IX", level: 100, cost: 100000, duration: {days: 5}}
  ]

  constructor: (@tier = 1) ->
    @type = 'Strength'
    super()

  strPercent: -> @tier*5

module.exports = exports = GuildStrength