
GuildBuilding = require "../GuildBuilding"

`/**
 * The GuildShop allows you to buy items, and upgrading it allows you to buy better items!
 *
 * @name GuildShop
 * @category Buildings
 * @package Guild Bases
 * @cost {level-up} 10000
 * @size {md}
 */`
class GuildShop extends GuildBuilding

  @size = GuildShop::size = "md"
  @desc = GuildShop::desc = "Upgrade this building to make your guild sell better items!"
  @levelupCost = GuildShop::levelupCost = (level) -> level*10000

  tiles: [
    0,  0,  0,  0,  0,
    0,  44, 49, 44, 0,
    0,  49, 49, 49, 0,
    0,  44, 49, 44, 0,
    0,  0,  0,  0,  0
  ]

module.exports = exports = GuildShop