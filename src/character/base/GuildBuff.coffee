
class GuildBuff

  tiers: @tiers = []

  constructor: ->
    @name = @tiers[@tier].name
    @refresh @tier

  refresh: (tier) ->
    @expire = Date.now() + @tiers[tier].duration

module.exports = exports = GuildBuff