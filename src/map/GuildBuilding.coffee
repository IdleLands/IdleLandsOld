
class GuildBuilding

  constructor: (@game, @guild, @name) ->

  @size = GuildBuilding::size = "sm"
  @levelupCost = GuildBuilding::levelupCost = (level) -> 0
  level: 0

  tiles: [
    0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0
  ]

module.exports = exports = GuildBuilding