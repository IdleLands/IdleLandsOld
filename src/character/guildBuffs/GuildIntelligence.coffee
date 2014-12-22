
GuildBuff = require "../base/GuildBuff"

`/**
  * The Intelligence I guild buff increases Intelligence.
  *
  * @name Intelligence I
  * @requirement {gold} 4000
  * @requirement {guild level} 20
  * @effect +5% INT
  * @duration 1 day
  * @category Intelligence
  * @package GuildBuffs
*/`
`/**
  * The Intelligence II guild buff increases Intelligence.
  *
  * @name Intelligence II
  * @requirement {gold} 9000
  * @requirement {guild level} 30
  * @effect +10% INT
  * @duration 1 day, 12 hours
  * @category Intelligence
  * @package GuildBuffs
*/`
`/**
  * The Intelligence III guild buff increases Intelligence.
  *
  * @name Intelligence III
  * @requirement {gold} 16000
  * @requirement {guild level} 40
  * @effect +15% INT
  * @duration 2 days
  * @category Intelligence
  * @package GuildBuffs
*/`
`/**
  * The Intelligence IV guild buff increases Intelligence.
  *
  * @name Intelligence IV
  * @requirement {gold} 25000
  * @requirement {guild level} 50
  * @effect +20% INT
  * @duration 2 days, 12 hours
  * @category Intelligence
  * @package GuildBuffs
*/`
`/**
  * The Intelligence V guild buff increases Intelligence.
  *
  * @name Intelligence V
  * @requirement {gold} 36000
  * @requirement {guild level} 60
  * @effect +25% INT
  * @duration 3 days
  * @category Intelligence
  * @package GuildBuffs
*/`
`/**
  * The Intelligence VI guild buff increases Intelligence.
  *
  * @name Intelligence VI
  * @requirement {gold} 49000
  * @requirement {guild level} 80
  * @effect +30% INT
  * @duration 3 days, 12 hours
  * @category Intelligence
  * @package GuildBuffs
*/`
`/**
  * The Intelligence VII guild buff increases Intelligence.
  *
  * @name Intelligence VII
  * @requirement {gold} 64000
  * @requirement {guild level} 80
  * @effect +35% INT
  * @duration 4 days
  * @category Intelligence
  * @package GuildBuffs
*/`
`/**
  * The Intelligence VIII guild buff increases Intelligence.
  *
  * @name Intelligence VIII
  * @requirement {gold} 81000
  * @requirement {guild level} 90
  * @effect +40% INT
  * @duration 4 days, 12 hours
  * @category Intelligence
  * @package GuildBuffs
*/`
`/**
  * The Intelligence IX guild buff increases Intelligence.
  *
  * @name Intelligence IX
  * @requirement {gold} 100000
  * @requirement {guild level} 100
  * @effect +45% INT
  * @duration 5 days
  * @category Intelligence
  * @package GuildBuffs
*/`
class GuildIntelligence extends GuildBuff

  @tiers = GuildIntelligence::tiers = [null,
    {name: "Intelligence I", level: 20, cost: 4000, duration: {days: 1}},
    {name: "Intelligence II", level: 30, cost: 9000, duration: {days: 1, hours: 12}},
    {name: "Intelligence III", level: 40, cost: 16000, duration: {days: 2}},
    {name: "Intelligence IV", level: 50, cost: 25000, duration: {days: 2, hours: 12}},
    {name: "Intelligence V", level: 60, cost: 36000, duration: {days: 3}},
    {name: "Intelligence VI", level: 70, cost: 49000, duration: {days: 3, hours: 12}},
    {name: "Intelligence VII", level: 80, cost: 64000, duration: {days: 4}},
    {name: "Intelligence VIII", level: 90, cost: 81000, duration: {days: 4, hours: 12}},
    {name: "Intelligence IX", level: 100, cost: 100000, duration: {days: 5}}
  ]

  constructor: (@tier = 1) ->
    @type = 'Intelligence'
    super()

  intPercent: -> @tier*5

module.exports = exports = GuildIntelligence