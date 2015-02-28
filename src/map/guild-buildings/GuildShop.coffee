
GuildBuilding = require "../GuildBuilding"

`/**
 * The GuildShop allows you to buy items, and upgrading it allows you to buy better items!
 *
 * @name GuildShop
 * @category Buildings
 * @package Guild
 * @cost {level-up} 10000
 * @effect {level-interval} 2 (Every 2 levels the shop items become slightly cheaper)
 * @effect {level-interval} 5 (Every 5 levels the shop quality goes up)
 * @effect {level-interval} 10 (Every 10 levels the shop gets another inventory slot)
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