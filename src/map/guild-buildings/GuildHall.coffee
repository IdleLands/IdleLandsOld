
GuildBuilding = require "../GuildBuilding"

class GuildHall extends GuildBuilding

  @size = GuildHall::size = "lg"
  @desc = GuildHall::desc = "Upgrade this building to make your other buildings more upgradeable!"
  @levelupCost = GuildHall::levelupCost = (level) -> level * 10000

  tiles: [
    0,  0,  0,  0,  0,  0,  0,
    0,  49, 49, 49, 49, 49, 0,
    0,  49, 49, 49, 49, 49, 0,
    0,  49, 49, 49, 49, 49, 0,
    0,  49, 49, 49, 49, 49, 0,
    0,  49, 49, 49, 49, 49, 0,
    0,  0,  0,  0,  0,  0,  0
  ]

module.exports = exports = GuildHall