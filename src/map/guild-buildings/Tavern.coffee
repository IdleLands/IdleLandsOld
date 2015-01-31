
GuildBuilding = require "../GuildBuilding"

class Tavern extends GuildBuilding

  @size = Tavern::size = "lg"
  @desc = Tavern::desc = "Upgrade this building to get your guildies drunk!"
  @levelupCost = Tavern::levelupCost = (level) -> level * 50000

  tiles: [
    0,  0,  0,  0,  0,  0,  0,
    0,  44, 39, 0,  45, 47, 0,
    0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,
    0,  44, 44, 0,  44, 0,  0,
    0,  46, 0,  0,  0,  46, 0,
    0,  0,  0,  0,  0,  0,  0
  ]

module.exports = exports = Tavern