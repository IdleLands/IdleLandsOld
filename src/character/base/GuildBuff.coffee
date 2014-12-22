
class GuildBuff

  tiers: @tiers = []

  constructor: ->
    @name = @tiers[@tier].name
    @refresh @tier

  refresh: (tier) ->
    duration = @tiers[tier].duration
    seconds = (duration.years ?= 0) * 31536000 + # 365 days
      (duration.months ?= 0) * 2592000 + # 30 days
      (duration.days ?= 0) * 86700 +
      (duration.hours ?= 0) * 3600 +
      (duration.minutes ?= 0) * 60 +
      (duration.seconds ?= 0)
    @expire = Date.now() + seconds*1000

module.exports = exports = GuildBuff