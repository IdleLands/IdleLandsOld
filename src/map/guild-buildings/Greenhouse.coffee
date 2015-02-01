
GuildBuilding = require "../GuildBuilding"

class Greenhouse extends GuildBuilding

  @size = Greenhouse::size = "lg"
  @desc = Greenhouse::desc = "Upgrade this area to produce more items for your guildies!"
  @levelupCost = Greenhouse::levelupCost = (level) -> level * 85000

  baseTile: 4

  tiles: [
    0,  0,  0,  0,  0,  0,  0,
    0,  16, 0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  16, 0,
    0,  0,  16, 0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  37, 0,  46, 0,
    0,  0,  0,  0,  0,  0,  0
  ]

module.exports = exports = Greenhouse