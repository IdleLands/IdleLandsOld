
GuildBuilding = require "../GuildBuilding"

class Mascot extends GuildBuilding

  @size = Mascot::size = "sm"
  @desc = Mascot::desc = "Upgrade this guy for bragging rights!"
  @levelupCost = Mascot::levelupCost = (level) -> level * 1000

  tiles: [
    0,  0,  0,
    0,  26, 0,
    0,  0,  0
  ]

module.exports = exports = Mascot