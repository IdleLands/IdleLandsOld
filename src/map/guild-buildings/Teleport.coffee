
GuildBuilding = require "../GuildBuilding"

class Teleport extends GuildBuilding

  @size = Teleport::size = "sm"
  @desc = Teleport::desc = "Upgrade this portal to unlock more destinations!"
  @levelupCost = Teleport::levelupCost = (level) -> level * 15000

  f =
    name: "Guild Teleporter"
    gid: 30
    type: "Teleport"
    properties:
      toLoc: "norkos"

  tiles: [
    0,  0,  0,
    0,  f,  0,
    0,  0,  0
  ]

module.exports = exports = Teleport