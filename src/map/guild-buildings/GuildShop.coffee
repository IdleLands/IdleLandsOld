
GuildBuilding = require "../GuildBuilding"

class GuildShop extends GuildBuilding

  @size = GuildShop::size = "md"
  @desc = GuildShop::desc = "Upgrade this building to make your guild sell better items!"
  @levelupCost = GuildShop::levelupCost = (level) -> level * 25000

  tiles: [
    0,  0,  0,  0,  0,
    0,  44, 49, 44, 0,
    0,  49, 49, 49, 0,
    0,  44, 49, 44, 0,
    0,  0,  0,  0,  0
  ]

module.exports = exports = GuildShop