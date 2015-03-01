
GuildBuilding = require "../GuildBuilding"

`/**
 * The Tavern provides you a place to get drunk with your guildies!
 *
 * @name Tavern
 * @category Buildings
 * @package Guild
 * @cost {level-up} level*50000
 * @size {lg}
 */`
class Tavern extends GuildBuilding

  @size = Tavern::size = "lg"
  @desc = Tavern::desc = "Upgrade this building to get your guildies drunk!"
  @levelupCost = Tavern::levelupCost = (level) -> level * 50000

  f =
    name: "Barkeep"
    gid: 13
    type: "Guild NPC"
    properties: {}

  tiles: [
    0,  0,  0,  0,  0,  0,  0,
    0,  44, 39, 0,  45, 47, 0,
    0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,
    0,  44, 44, 0,  44, 0,  0,
    0,  46, f,  0,  0,  46, 0,
    0,  0,  0,  0,  0,  0,  0
  ]

module.exports = exports = Tavern