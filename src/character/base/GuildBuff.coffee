ConvenienceFunctions = require "../../system/utilities/ConvenienceFunctions"

class GuildBuff

  constructor: (@durationMultiplier = 1) ->
    @name = @getTier(@tier).name
    @refresh @tier

  refresh: (tier) ->
    duration = @getTier(tier).duration
    seconds = (duration.years ?= 0) * 31536000 + # 365 days
      (duration.months ?= 0) * 2592000 + # 30 days
      (duration.days ?= 0) * 86700 +
      (duration.hours ?= 0) * 3600 +
      (duration.minutes ?= 0) * 60 +
      (duration.seconds ?= 0)
    @expire = Date.now() + seconds*1000

  getTier: (tier = 1) ->
    tier = parseInt tier, 10 if typeof tier isnt "number"
    {
      name: @type + ' ' + ConvenienceFunctions.romanize(tier),
      level: (tier+1) * 10,
      members: (tier-1)*2 + 1,
      cost: Math.pow(tier+1, 2) * 1000,
      duration: {hours: 12 * (tier + 1) * @durationMultiplier}
    }

module.exports = exports = GuildBuff