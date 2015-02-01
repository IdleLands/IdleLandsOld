
GuildBuilding = require "../GuildBuilding"

`/**
 * The Enchantress allows you to get better enchantments on your items, for a price!
 *
 * @name Enchantress
 * @category Buildings
 * @package Guild Bases
 * @cost {level-up} level*5000
 * @size {sm}
 */`
class Enchantress extends GuildBuilding

  @size = Enchantress::size = "sm"
  @desc = Enchantress::desc = "Upgrade this magic user to get better enchanting capabilities!"
  @levelupCost = Enchantress::levelupCost = (level) -> level * 5000

  f =
    name: "Enchantress"
    gid: 21
    type: "Guild NPC"
    properties:
      forceEvent: "enchant"

  tiles: [
    0,  0,  0,
    0,  f,  0,
    0,  0,  0
  ]

module.exports = exports = Enchantress