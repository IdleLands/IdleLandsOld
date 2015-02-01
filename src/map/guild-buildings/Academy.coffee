
GuildBuilding = require "../GuildBuilding"

`/**
 * The Academy affects the capability of your minor permanent buffs as well as the major buffs you can purchase for a limited time.
 *
 * @name Academy
 * @category Buildings
 * @package Guild Bases
 * @cost {level-up} level*50000
 * @size {md}
 */`
class Academy extends GuildBuilding

  @size = Academy::size = "md"
  @desc = Academy::desc = "Upgrade this building to make your buffs better and get some permanent ones!"
  @levelupCost = Academy::levelupCost = (level) -> level * 50000

  tiles: [
    0,  0,  0,  0,  0,
    0,  12, 0, 44,  0,
    0,  0,  0,  0,  0,
    0,  44, 0, 44,  0,
    0,  0,  0,  0,  0
  ]

module.exports = exports = Academy