
GuildBuilding = require "../GuildBuilding"

class GuildHall extends GuildBuilding

  @size = GuildHall::size = "lg"
  @levelupCost = GuildHall::levelupCost = (level) -> level * 100000

  tileRef: [
    49
  ]

  # 0 is treated as empty space, tilerRef-1 is applied to everything else.
  tiles: [
    0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0
  ]

module.exports = exports = GuildHall