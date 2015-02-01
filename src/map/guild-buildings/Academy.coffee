
GuildBuilding = require "../GuildBuilding"

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