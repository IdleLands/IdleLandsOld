
_ = require "lodash"

GuildBuilding = require "../GuildBuilding"
Constants = require "../../system/utilities/Constants"

`/**
 * The Mascot looks really nice in the courtyard. Upgrading it provides bragging rights!
 *
 * @name Mascot
 * @category Buildings
 * @package Guild Bases
 * @cost {level-up} level*15000
 * @property MascotID (Any valid string ID referencing the tile map in the game)
 * @property Quote (Any string)
 * @property Name (Any string)
 * @size {sm}
 */`
class Mascot extends GuildBuilding

  @size = Mascot::size = "sm"
  @desc = Mascot::desc = "Upgrade this guy for bragging rights!"
  @levelupCost = Mascot::levelupCost = (level) -> level * 15000

  tiles: [
    0,  0,  0,
    0,  0,  0,
    0,  0,  0
  ]

  constructor: (@game, @guild, @name) ->
    super @game, @guild, @name

    mascotId = parseInt Constants.revGidMap[@getProperty "MascotID"]
    mascotQuote = @getProperty "Quote"
    mascotName = @getProperty "Name"

    f =
      name: mascotName or "Mascot"
      gid:  if _.isNaN mascotId then 26 else mascotId
      type: "Guild NPC"
      properties:
        flavorText: mascotQuote

    @tiles = [
      0,  0,  0,
      0,  f,  0,
      0,  0,  0
    ]

module.exports = exports = Mascot