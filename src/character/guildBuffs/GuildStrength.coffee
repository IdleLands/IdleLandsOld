GuildBuff = require "../base/GuildBuff"

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