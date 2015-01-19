
GuildBuff = require "../base/GuildBuff"

`/**
  * The Constitution I guild buff increases Constitution.
  *
  * @name Constitution I
  * @requirement {gold} 4000
  * @requirement {guild-level} 20
  * @requirement {guild-members} 1
  * @effect +5% CON
  * @duration 1 day
  * @category Constitution
  * @package GuildBuffs
*/`
`/**
  * The Constitution II guild buff increases Constitution.
  *
  * @name Constitution II
  * @requirement {gold} 9000
  * @requirement {guild-level} 30
  * @requirement {guild-members} 1
  * @effect +10% CON
  * @duration 1 day, 12 hours
  * @category Constitution
  * @package GuildBuffs
*/`
`/**
  * The Constitution III guild buff increases Constitution.
  *
  * @name Constitution III
  * @requirement {gold} 16000
  * @requirement {guild-level} 40
  * @requirement {guild-members} 4
  * @effect +15% CON
  * @duration 2 days
  * @category Constitution
  * @package GuildBuffs
*/`
`/**
  * The Constitution IV guild buff increases Constitution.
  *
  * @name Constitution IV
  * @requirement {gold} 25000
  * @requirement {guild-level} 50
  * @requirement {guild-members} 4
  * @effect +20% CON
  * @duration 2 days, 12 hours
  * @category Constitution
  * @package GuildBuffs
*/`
`/**
  * The Constitution V guild buff increases Constitution.
  *
  * @name Constitution V
  * @requirement {gold} 36000
  * @requirement {guild-level} 60
  * @requirement {guild-members} 9
  * @effect +25% CON
  * @duration 3 days
  * @category Constitution
  * @package GuildBuffs
*/`
`/**
  * The Constitution VI guild buff increases Constitution.
  *
  * @name Constitution VI
  * @requirement {gold} 49000
  * @requirement {guild-level} 70
  * @requirement {guild-members} 9
  * @effect +30% CON
  * @duration 3 days, 12 hours
  * @category Constitution
  * @package GuildBuffs
*/`
`/**
  * The Constitution VII guild buff increases Constitution.
  *
  * @name Constitution VII
  * @requirement {gold} 64000
  * @requirement {guild-level} 80
  * @requirement {guild-members} 15
  * @effect +35% CON
  * @duration 4 days
  * @category Constitution
  * @package GuildBuffs
*/`
`/**
  * The Constitution VIII guild buff increases Constitution.
  *
  * @name Constitution VIII
  * @requirement {gold} 81000
  * @requirement {guild-level} 90
  * @requirement {guild-members} 15
  * @effect +40% CON
  * @duration 4 days, 12 hours
  * @category Constitution
  * @package GuildBuffs
*/`
`/**
  * The Constitution IX guild buff increases Constitution.
  *
  * @name Constitution IX
  * @requirement {gold} 100000
  * @requirement {guild-level} 100
  * @requirement {guild-members} 20
  * @effect +45% CON
  * @duration 5 days
  * @category Constitution
  * @package GuildBuffs
*/`
class GuildConstitution extends GuildBuff

  @tiers = GuildConstitution::tiers = [null,
    {name: "Constitution I", level: 20, members: 1, cost: 4000, duration: {days: 1}},
    {name: "Constitution II", level: 30, members: 1, cost: 9000, duration: {days: 1, hours: 12}},
    {name: "Constitution III", level: 40, members: 4, cost: 16000, duration: {days: 2}},
    {name: "Constitution IV", level: 50, members: 4, cost: 25000, duration: {days: 2, hours: 12}},
    {name: "Constitution V", level: 60, members: 9, cost: 36000, duration: {days: 3}},
    {name: "Constitution VI", level: 70, members: 9, cost: 49000, duration: {days: 3, hours: 12}},
    {name: "Constitution VII", level: 80, members: 15, cost: 64000, duration: {days: 4}},
    {name: "Constitution VIII", level: 90, members: 15, cost: 81000, duration: {days: 4, hours: 12}},
    {name: "Constitution IX", level: 100, members: 20, cost: 100000, duration: {days: 5}}
  ]

  constructor: (@tier = 1) ->
    @type = 'Constitution'
    super()

  conPercent: -> @tier*5

module.exports = exports = GuildConstitution