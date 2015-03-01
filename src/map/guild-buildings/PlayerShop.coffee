
GuildBuilding = require "../GuildBuilding"

`/**
 * The PlayerShop allows you to sell items, and upgrading it allows you to sell more items!
 *
 * @name PlayerShop
 * @category Buildings
 * @package Guild
 * @cost {level-up} 75000
 * @size {md}
 */`
class PlayerShop extends GuildBuilding

  @size = PlayerShop::size = "md"
  @desc = PlayerShop::desc = "Upgrade this building to allow your guildies to sell more of their items!"
  @levelupCost = PlayerShop::levelupCost = (level) -> 75000

  tiles: [
    0,  0,  0,  0,  0,
    0,  44, 0,  44, 0,
    0,  0,  0,  0,  0,
    0,  44, 0,  44, 0,
    0,  0,  0,  0,  0
  ]

module.exports = exports = PlayerShop