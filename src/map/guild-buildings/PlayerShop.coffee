
GuildBuilding = require "../GuildBuilding"

class PlayerShop extends GuildBuilding

  @size = PlayerShop::size = "md"
  @desc = PlayerShop::desc = "Upgrade this building to allow your guildies to sell more of their items!"
  @levelupCost = PlayerShop::levelupCost = (level) -> level * 15000

  tiles: [
    0,  0,  0,  0,  0,
    0,  44, 0,  44, 0,
    0,  0,  0,  0,  0,
    0,  44, 0,  44, 0,
    0,  0,  0,  0,  0
  ]

module.exports = exports = PlayerShop