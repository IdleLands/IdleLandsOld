GuildBuff = require "../base/GuildBuff"

class GuildStrength extends GuildBuff

  @tiers = GuildStrength::tiers = [null,
    {name: "Strength I", level: 20, cost: 4000, duration: 86400},
    {name: "Strength II", level: 30, cost: 9000, duration: 129600000},
    {name: "Strength III", level: 40, cost: 16000, duration: 172800000},
    {name: "Strength IV", level: 50, cost: 25000, duration: 216000000},
    {name: "Strength V", level: 60, cost: 36000, duration: 259200000},
    {name: "Strength VI", level: 70, cost: 49000, duration: 302400000},
    {name: "Strength VII", level: 80, cost: 64000, duration: 345600000},
    {name: "Strength VIII", level: 90, cost: 81000, duration: 388800000},
    {name: "Strength IX", level: 100, cost: 100000, duration: 432000000}
  ]

  constructor: (@tier = 1) ->
    @type = 'Strength'
    super()

  strPercent: -> @tier*5

module.exports = exports = GuildStrength