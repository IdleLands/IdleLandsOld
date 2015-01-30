
class GuildBuilding

  constructor: (@game, @guild) ->

  @size = GuildBuilding::size = "sm"
  @levelupCost = GuildBuilding::levelupCost = (level) -> 0
  level: 0

module.exports = exports = GuildBuilding