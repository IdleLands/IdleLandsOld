
GuildBuilding = require "../GuildBuilding"

`/**
 * The Teleport allows you to specify a teleport to anywhere in the world!
 *
 * @name Teleport
 * @category Buildings
 * @package Guild Bases
 * @cost {level-up} level*15000
 * @property Destination (Any valid teleport location)
 * @size {sm}
 */`
class Teleport extends GuildBuilding

  @size = Teleport::size = "sm"
  @desc = Teleport::desc = "Upgrade this portal to unlock more destinations!"
  @levelupCost = Teleport::levelupCost = (level) -> level * 15000

  properties: [
    { name: "Destination", values: ["frigri", "maeles", "norkos", "vocalnus"]}
  ]

  constructor: (@game, @guild, @name) ->
    super @game, @guild, @name

    f =
      name: "Guild Teleporter"
      gid: 30
      type: "Teleport"
      properties:
        toLoc: "norkos"

    @tiles = [
      0,  0,  0,
      0,  f,  0,
      0,  0,  0
    ]

  tiles: [
    0,  0,  0,
    0,  0,  0,
    0,  0,  0
  ]

module.exports = exports = Teleport