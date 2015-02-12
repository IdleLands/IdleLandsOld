
GuildBuilding = require "../GuildBuilding"

`/**
 * The Mascot looks really nice in the courtyard. Upgrading it provides bragging rights!
 *
 * @name Mascot
 * @category Buildings
 * @package Guild Bases
 * @cost {level-up} level*1000
 * @size {sm}
 */`
class Mascot extends GuildBuilding

  @size = Mascot::size = "sm"
  @desc = Mascot::desc = "Upgrade this guy for bragging rights!"
  @levelupCost = Mascot::levelupCost = (level) -> level * 1000

  f =
    name: "Mascot"
    gid: 26
    type: "Guild NPC"
    properties: {}

  tiles: [
    0,  0,  0,
    0,  f,  0,
    0,  0,  0
  ]

module.exports = exports = Mascot