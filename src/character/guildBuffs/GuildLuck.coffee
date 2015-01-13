
GuildBuff = require "../base/GuildBuff"

`/**
  * The Luck I guild buff increases Luck.
  *
  * @name Luck I
  * @requirement {gold} 4000
  * @requirement {guild-level} 20
  * @requirement {guild-members} 1
  * @effect +1% LUCK
  * @duration 1 day
  * @category Luck
  * @package GuildBuffs
*/`
`/**
  * The Luck II guild buff increases Luck.
  *
  * @name Luck II
  * @requirement {gold} 9000
  * @requirement {guild-level} 30
  * @requirement {guild-members} 1
  * @effect +2% LUCK
  * @duration 1 day, 12 hours
  * @category Luck
  * @package GuildBuffs
*/`
`/**
  * The Luck III guild buff increases Luck.
  *
  * @name Luck III
  * @requirement {gold} 16000
  * @requirement {guild-level} 40
  * @requirement {guild-members} 4
  * @effect +3% LUCK
  * @duration 2 days
  * @category Luck
  * @package GuildBuffs
*/`
`/**
  * The Luck IV guild buff increases Luck.
  *
  * @name Luck IV
  * @requirement {gold} 25000
  * @requirement {guild-level} 50
  * @requirement {guild-members} 4
  * @effect +4% LUCK
  * @duration 2 days, 12 hours
  * @category Luck
  * @package GuildBuffs
*/`
`/**
  * The Luck V guild buff increases Luck.
  *
  * @name Luck V
  * @requirement {gold} 36000
  * @requirement {guild-level} 60
  * @requirement {guild-members} 9
  * @effect +5% LUCK
  * @duration 3 days
  * @category Luck
  * @package GuildBuffs
*/`
`/**
  * The Luck VI guild buff increases Luck.
  *
  * @name Luck VI
  * @requirement {gold} 49000
  * @requirement {guild-level} 80
  * @requirement {guild-members} 9
  * @effect +6% LUCK
  * @duration 3 days, 12 hours
  * @category Luck
  * @package GuildBuffs
*/`
`/**
  * The Luck VII guild buff increases Luck.
  *
  * @name Luck VII
  * @requirement {gold} 64000
  * @requirement {guild-level} 80
  * @requirement {guild-members} 15
  * @effect +7% LUCK
  * @duration 4 days
  * @category Luck
  * @package GuildBuffs
*/`
`/**
  * The Luck VIII guild buff increases Luck.
  *
  * @name Luck VIII
  * @requirement {gold} 81000
  * @requirement {guild-level} 90
  * @requirement {guild-members} 15
  * @effect +8% LUCK
  * @duration 4 days, 12 hours
  * @category Luck
  * @package GuildBuffs
*/`
`/**
  * The Luck IX guild buff increases Luck.
  *
  * @name Luck IX
  * @requirement {gold} 100000
  * @requirement {guild-level} 100
  * @requirement {guild-members} 20
  * @effect +9% LUCK
  * @duration 5 days
  * @category Luck
  * @package GuildBuffs
*/`
class GuildLuck extends GuildBuff

  @tiers = GuildLuck::tiers = [null,
    {name: "Luck I", level: 20, members: 1, cost: 4000, duration: {days: 1}},
    {name: "Luck II", level: 30, members: 1, cost: 9000, duration: {days: 1, hours: 12}},
    {name: "Luck III", level: 40, members: 4, cost: 16000, duration: {days: 2}},
    {name: "Luck IV", level: 50, members: 4, cost: 25000, duration: {days: 2, hours: 12}},
    {name: "Luck V", level: 60, members: 9, cost: 36000, duration: {days: 3}},
    {name: "Luck VI", level: 70, members: 9, cost: 49000, duration: {days: 3, hours: 12}},
    {name: "Luck VII", level: 80, members: 15, cost: 64000, duration: {days: 4}},
    {name: "Luck VIII", level: 90, members: 15, cost: 81000, duration: {days: 4, hours: 12}},
    {name: "Luck IX", level: 100, members: 20, cost: 100000, duration: {days: 5}}
  ]

  constructor: (@tier = 1) ->
    @type = 'Luck'
    super()

  luckPercent: -> @tier

module.exports = exports = GuildLuck