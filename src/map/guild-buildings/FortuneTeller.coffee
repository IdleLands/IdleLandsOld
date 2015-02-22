
GuildBuilding = require "../GuildBuilding"

`/**
 * The FortuneTeller allows you to get better providences!
 *
 * @name FortuneTeller
 * @category Buildings
 * @package Guild Bases
 * @cost {level-up} 55000+[20000*level/100]
 * @property Name (Any string)
 * @size {sm}
 */`
class FortuneTeller extends GuildBuilding

  @size = FortuneTeller::size = "sm"
  @desc = FortuneTeller::desc = "Upgrade this crystal ball user to get better providences!"
  @levelupCost = FortuneTeller::levelupCost = (level) -> 55000+(20000*Math.floor level/100)

  tiles: [
    0,  0,  0,
    0,  0,  0,
    0,  0,  0
  ]

  constructor: (@game, @guild, @name) ->
    super @game, @guild, @name

    name = @getProperty "Name"

    f =
      name: name or "Fortune Teller"
      gid: 23
      type: "Guild NPC"
      properties:
        forceEvent: "providence"
        isGuild: yes

    @tiles = [
      0,  0,  0,
      0,  f,  0,
      0,  0,  0
    ]

module.exports = exports = FortuneTeller